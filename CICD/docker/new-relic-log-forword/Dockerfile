##get pre-compiled Fluent Bit output plugin for New Relic
https://github.com/newrelic/newrelic-fluent-bit-output/releases/tag/v1.17.3
https://docs.newrelic.com/docs/logs/forward-logs/fluent-bit-plugin-log-forwarding/

## or install it on host machine and copy the "out_newrelic-linux-amd64-1.17.3.so" inside container
https://github.com/newrelic/newrelic-fluent-bit-output

####
FROM nginx
RUN apt-get update && \
    apt-get install -y curl gpg vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Step 3: Add the Fluent Bit repository key
RUN curl https://packages.fluentbit.io/fluentbit.key | gpg --dearmor -o /usr/share/keyrings/fluentbit-keyring.gpg

# Step 4: Install Fluent Bit
RUN curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh

# Step 6: Build the New Relic Fluent Bit plugin for Linux/amd64
RUN mkdir -p /newrelic-fluent-bit-output
WORKDIR /newrelic-fluent-bit-output
COPY out_newrelic-linux-amd64-dev.so /newrelic-fluent-bit-output/

# Your additional configuration for fluent-bit
COPY fluent-bit.conf /etc/fluent-bit/fluent-bit.conf
COPY plugins-new.conf /etc/fluent-bit/plugins.conf

# Step 7: Start NGINX when the container runs
#CMD ["sh", "-c", "nginx -g 'daemon off;' 2>&1 | tee /var/log/nginx/app.log"]
CMD ["sh", "-c", "/opt/fluent-bit/bin/fluent-bit -c /etc/fluent-bit/fluent-bit.conf & nginx -g 'daemon off;' 2>&1 | tee /var/log/nginx/app.log"]

