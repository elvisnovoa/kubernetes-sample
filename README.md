
Run the following command to import sample data
```commandline
$ mongoimport --jsonArray --db test --collection user --file sample-data.json
```

Start the app and POST to the following endpoint for login
```commandline
$ curl -i -X POST -H "Content-Type:application/json" -d "{  \"username\" : \"ironman\",  \"password\" : \"endgame\" }" http://localhost:8080/login

HTTP/1.1 200 
Content-Type: application/json;charset=UTF-8
Transfer-Encoding: chunked
Date: Tue, 19 Feb 2019 03:20:04 GMT

{"id":"5c6b6f7da1be94f4f5ee2e64","username":"ironman","password":"endgame","firstName":"Tony","lastName":"Stark"}
```