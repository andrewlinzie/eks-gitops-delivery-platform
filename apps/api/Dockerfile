# Use a lightweight Python base image
FROM python:3.8-slim

# Set working directory
WORKDIR /app

# Copy dependency list and install
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy application code
COPY . .

# Expose the application port
EXPOSE 5000

# Run the app using gunicorn (production-ready)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]