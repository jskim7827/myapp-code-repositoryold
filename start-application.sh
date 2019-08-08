#!/usr/bin/env bash



/opt/aws/amazon-cloudwatch-agent/bin/start-amazon-cloudwatch-agent &​

python manage.py runserver 0.0.0.0:8000
