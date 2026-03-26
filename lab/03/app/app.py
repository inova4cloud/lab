import os

import pytds
from flask import Flask

app = Flask(__name__)


def get_motd() -> str:
    server = os.getenv("SQL_SERVER_FQDN")
    database = os.getenv("SQL_DATABASE")
    username = os.getenv("SQL_USERNAME")
    password = os.getenv("SQL_PASSWORD")

    if not all([server, database, username, password]):
        return "Hello world from lab/03 Python App Service! (SQL not configured)"

    with pytds.connect(server=server, database=database, user=username, password=password) as conn:
        with conn.cursor() as cur:
            cur.execute(
                """
                IF OBJECT_ID('dbo.motd', 'U') IS NULL
                BEGIN
                    CREATE TABLE dbo.motd (
                        id INT IDENTITY(1,1) PRIMARY KEY,
                        message NVARCHAR(400) NOT NULL,
                        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
                    )
                END
                """
            )
            cur.execute("SELECT COUNT(1) FROM dbo.motd")
            count = cur.fetchone()[0]
            if count == 0:
                cur.execute(
                    "INSERT INTO dbo.motd (message) VALUES (%s)",
                    ["Hello world from MOTD table in Azure SQL Database!"],
                )
                conn.commit()

            cur.execute("SELECT TOP 1 message FROM dbo.motd ORDER BY updated_at DESC, id DESC")
            row = cur.fetchone()
            return row[0] if row else "Hello world from lab/03 Python App Service!"


@app.get("/")
def hello_world():
    try:
        return get_motd()
    except Exception as ex:
        return f"Hello world from lab/03 Python App Service! (SQL error: {ex})"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
