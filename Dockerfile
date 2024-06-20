FROM ruby:3.2.3
WORKDIR /usr/src/app

COPY . .

ENTRYPOINT ["./entrypoint.sh"]
CMD [ "rails", "s", "-b", "0.0.0.0"]
