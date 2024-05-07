FROM python:3.10-slim-bullseye
RUN apt-get clean
RUN apt-get update
RUN apt-get install -y curl pkg-config build-essential libnss-myhostname git unzip
WORKDIR /phoenixd
COPY phoenix-0.1.4-linux-x64.zip /phoenixd/phoenix-0.1.4-linux-x64.zip
RUN unzip /phoenixd/phoenix-0.1.4-linux-x64.zip
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"
RUN apt-get install -y apt-utils wget
RUN echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql-client-14
WORKDIR /lnbits
RUN git clone https://github.com/lnbits/lnbits.git /lnbits
RUN mkdir data
RUN poetry install --only main
ENV LNBITS_PORT="5000"
ENV LNBITS_HOST="0.0.0.0"
EXPOSE 5000
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]