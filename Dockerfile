FROM jolielang/jolie:edge

WORKDIR /app
COPY . .

CMD ["jolie", "main.ol"]