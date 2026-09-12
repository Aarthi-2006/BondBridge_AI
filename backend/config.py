import os
import tempfile

# Aiven SSL certificate
ssl_ca_content = os.environ.get("AIVEN_SSL_CA")

ssl_ca_path = None

if ssl_ca_content:
    ssl_ca_path = os.path.join(tempfile.gettempdir(), "aiven-ca.pem")

    with open(ssl_ca_path, "w") as f:
        f.write(ssl_ca_content)

DB_CONFIG = {
    "host": os.environ.get(
        "DB_HOST",
        "mysql-1451f425-tcarts-248.g.aivencloud.com"
    ),

    "port": int(os.environ.get("DB_PORT", "28142")),

    "user": os.environ.get(
        "DB_USER",
        "avnadmin"
    ),

    "password": os.environ.get(
        "DB_PASSWORD"
    ),

    "database": os.environ.get(
        "DB_NAME",
        "bondbridge_ai"
    ),

    "ssl_ca": ssl_ca_path
}