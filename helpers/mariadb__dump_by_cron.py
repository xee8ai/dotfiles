#!/usr/bin/env python3

from datetime import date
import os
import os.path
from pathlib import Path
from pprint import pprint
import shutil
import subprocess
import time


################################################################################
################################################################################
class DatabaseBackuper:

    keep = {
        "daily": 8,  # keep the last n days
        "weekly": 5,  # keep the last n sunday backups
        "monthly": 7,  # keep the last n first day of month backups
    }

    description = "backup_by_cron"

    dump_script = Path("/root/bin/mariadb__dump_now.sh")
    dump_dir = Path("/root/db_dumps/cron")

    # filled from <dump_script>
    databases_to_be_dumped = []
    database_count = None

    ############################################################################
    def __init__(self):

        self.extract_databases_from_dump_script()
        self.database_count = len(self.databases_to_be_dumped)
        self.do_backup()
        self.create_hardlinks()
        self.delete_old_backups()

    ############################################################################
    def extract_databases_from_dump_script(self):
        with open(self.dump_script, 'r') as fh:
            lines = fh.readlines()

        in_database_definition = False
        for line in lines:
            l = line.strip()

            if in_database_definition:
                if l == '"':
                    return
                if l:
                    self.databases_to_be_dumped.append(l)
                continue

            if l == 'DATABASES="':
                in_database_definition = True

    ############################################################################
    def do_backup(self):
        dirs = ["daily", "weekly", "monthly"]
        for d in dirs:
            p = Path(self.dump_dir, d)
            print(f"Creating {p}")
            os.makedirs(str(p), mode=0o750, exist_ok=True)

        subprocess.call(
            [str(self.dump_script), "cron", str(Path(self.dump_dir, "daily"))]
        )

    ############################################################################
    def create_hardlinks(self):
        p = Path(self.dump_dir, "daily")
        files = [
            f for f in os.listdir(str(p)) if os.path.isfile(os.path.join(str(p), f))
        ]
        files.sort()

        for i in range(self.database_count):
            if not files:
                continue
            last_file = files.pop()
            src = str(Path(self.dump_dir, "daily", last_file))

            if date.today().isoweekday() == 7:  # sunday
                dst_weekly = str(Path(self.dump_dir, "weekly", last_file))
                os.link(src, dst_weekly)

            if last_file[8:10] == "01":
                dst_monthly = str(Path(self.dump_dir, "monthly", last_file))
                os.link(src, dst_monthly)

    ############################################################################
    def delete_old_backups(self):
        for d, keep in self.keep.items():
            p = Path(self.dump_dir, d)
            files = [
                f for f in os.listdir(str(p)) if os.path.isfile(os.path.join(str(p), f))
            ]
            files.sort(reverse=True)
            while len(files) > (self.database_count * keep):
                f = files.pop()
                Path(p, f).unlink()


################################################################################
################################################################################
################################################################################
if __name__ == "__main__":
    db = DatabaseBackuper()
