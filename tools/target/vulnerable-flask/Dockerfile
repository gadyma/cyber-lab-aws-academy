# Minimal deliberately-vulnerable Flask app (SSTI). Built locally by the target
# so the lab does not depend on a third-party Docker Hub image.
FROM python:3.11-slim
RUN pip install --no-cache-dir flask==3.0.3
WORKDIR /app
COPY app.py /app/app.py
# Default flag; plant-flags.sh overwrites /flag.txt per student when enabled.
RUN echo 'FLAG{flask_default}' > /flag.txt
EXPOSE 5000
CMD ["python", "app.py"]
