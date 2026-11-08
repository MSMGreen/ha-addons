# Official Music Assistant server with the patched Jellyfin provider laid over it.
ARG BUILD_FROM
FROM ${BUILD_FROM}

COPY jellyfin/ /app/venv/lib/python3.14/site-packages/music_assistant/providers/jellyfin/
COPY seed-data.sh /usr/local/bin/seed-data.sh
COPY seed_data.py /addon-seed/seed_data.py
RUN chmod +x /usr/local/bin/seed-data.sh

ENTRYPOINT ["/usr/local/bin/seed-data.sh"]
