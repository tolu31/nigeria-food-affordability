"""Load the World Bank Nigeria RTFP file into the raw schema of PostgreSQL.

Raw layer rule: load everything as TEXT, exactly as in the source.
The load is all-or-nothing: a row-count mismatch rolls it back.
"""
import csv
import logging
import os
import time
from pathlib import Path

import psycopg
from dotenv import load_dotenv

load_dotenv()

RAW_DIR = Path("data/raw")
SCHEMA, TABLE = "raw", "rtfp"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    handlers=[logging.FileHandler("pipeline/load_raw.log"), logging.StreamHandler()],
)
log = logging.getLogger("load_raw")


def find_source() -> Path:
    files = sorted(RAW_DIR.glob("NGA_RTFP_mkt*.csv"))
    if len(files) != 1:
        raise SystemExit(
            f"Expected exactly one NGA_RTFP_mkt*.csv in {RAW_DIR.resolve()}, found {len(files)}"
        )
    return files[0]


def read_header(path: Path) -> list[str]:
    with path.open(encoding="utf-8-sig", newline="") as f:
        return next(csv.reader(f))


def count_source_rows(path: Path) -> int:
    with path.open(encoding="utf-8-sig", newline="") as f:
        reader = csv.reader(f)
        next(reader)
        return sum(1 for _ in reader)


def main() -> None:
    path = find_source()
    columns = read_header(path)
    col_defs = ", ".join(f'"{c}" TEXT' for c in columns)

    conn_kwargs = dict(
        host=os.environ["PGHOST"],
        port=os.environ["PGPORT"],
        dbname=os.environ["PGDATABASE"],
        user=os.environ["PGUSER"],
        password=os.environ["PGPASSWORD"],
        client_encoding="UTF8",
    )

    start = time.time()
    with psycopg.connect(**conn_kwargs) as conn:
        conn.execute(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA}")
        with conn.cursor() as cur:
            cur.execute(f'DROP TABLE IF EXISTS {SCHEMA}."{TABLE}"')
            cur.execute(f'CREATE TABLE {SCHEMA}."{TABLE}" ({col_defs})')
            copy_sql = f'COPY {SCHEMA}."{TABLE}" FROM STDIN WITH (FORMAT csv, HEADER true)'
            with path.open("rb") as f, cur.copy(copy_sql) as copy:
                while chunk := f.read(1024 * 1024):
                    copy.write(chunk)
            cur.execute(f'SELECT COUNT(*) FROM {SCHEMA}."{TABLE}"')
            db_rows = cur.fetchone()[0]

        src_rows = count_source_rows(path)
        status = "MATCH" if db_rows == src_rows else "MISMATCH"
        log.info(
            "%s -> %s.%s columns=%d db=%s source=%s %s (%.1fs)",
            path.name, SCHEMA, TABLE, len(columns),
            f"{db_rows:,}", f"{src_rows:,}", status, time.time() - start,
        )
        if status == "MISMATCH":
            raise RuntimeError("Row count mismatch, load rolled back")
    log.info("Done: file loaded and reconciled")


if __name__ == "__main__":
    main()