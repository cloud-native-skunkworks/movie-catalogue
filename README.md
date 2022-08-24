
[<img src="images/1hr.png" width="750px;">](https://www.youtube.com/watch?v=unRRnOfxa0s)

This is the companion repository with some sample code as used in the video. It has working code for uploading and retrieval of movies. _Why not write the rest?_


### Setup

- Connect to a local kubernetes cluster
- Run the postgres installer `./scripts/install-postgres.sh`
- Either run the API locally or push your own docker image and modify the helm chart

## Post a movie

```
curl -X POST http://localhost:8081/movie -H 'Content-Type: application/json' -d '{
    "title": "Avengers: Age of Ultron",
    "year": 2016,
    "cast": [
      "Robert Downey, Jr.",
      "Chris Evans",
      "Chris Hemsworth",
      "Mark Ruffalo"
    ],
    "genres": [
      "Action"
    ]
}'
```

## Retrieve a movie

```
curl localhost:8081/movies/year/2016
```