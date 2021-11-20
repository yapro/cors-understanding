FROM nginx:1.21.3

# используем apt-get вместо apt, чтобы не получать: WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
RUN apt-get update

RUN apt-get install -y openssl

# генерируем сертификаты ( по статье: https://www.shellhacks.com/ru/create-csr-openssl-without-prompt-non-interactive/ )
# front.local
# RUN cd /tmp \
#     && openssl genrsa -out "devcert.key" 2048 \
#     && openssl req -new -key "devcert.key" -out "devcert.csr" -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com" \
#     && openssl x509 -req -days 365 -in "devcert.csr" -signkey "devcert.key" -out "devcert.crt"

# back.local
RUN cd /var/tmp \
    && openssl genrsa -out "devcert.key" 2048 \
    && openssl req -new -key "devcert.key" -out "devcert.csr" -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com" \
    && openssl x509 -req -days 365 -in "devcert.csr" -signkey "devcert.key" -out "devcert.crt"
