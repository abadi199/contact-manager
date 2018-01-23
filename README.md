# Contact Manager

## Accessing the web app on Azure
This web app has been deployed to Azure via docker and can be access at this URL:
https://contactmanagerabadi.azurewebsites.net

## Requirement 
- Dotnet Core 2.0 SDK
- Node.js and NPM
- sqlite3

## Build the application locally

```
npm install
npm run build
npm run reset-db
```

## Run the application locally

After a successful build you can start the web application by executing the following command in your terminal:

```
npm start
```

After the application has started visit [http://localhost:5000](http://localhost:5000) in your preferred browser.