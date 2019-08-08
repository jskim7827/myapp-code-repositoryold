FROM python:3.4-jessie



COPY . .

RUN pip install -r requirements.txt \
    && curl -OLs https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb \
    && dpkg -i -E ./amazon-cloudwatch-agent.deb \
    && mv .aws /root/ \
    && cp amazon-cloudwatch-agent.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    && cp amazon-cloudwatch-agent.toml /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.toml

EXPOSE 8000


CMD ["sh", "start-application.sh"]
