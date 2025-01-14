FROM node:18.20.4-slim

WORKDIR /app/

COPY package.json .

RUN npm i

COPY . .

EXPOSE 3000

CMD [ "npm", "run", "dev"]

# We'll want to reinstall the dependencies if that file changes, but use cached dependencies if the file is unchanged. 
# So, start by copying only that file first, then install the dependencies, and finally copy everything else. 
# Then, we only need to recreate the npm dependencies if there was a change to the package.json file.