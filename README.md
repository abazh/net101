# NET101
NET101 is a repository to learn about network from traditional to programmable network using mininet environment.

## Requirement
You need to install mininet on your Ubuntu Linux Server. Using this repo, you can just start the mininet container:

```
    docker compose up -d
    docker compose exec -it mininet bash
```
## Static and Dynamic Routing

```mermaid
graph LR;
%%Colors

classDef host fill:#fffb05, stroke:#000000;
classDef switch fill:#1fd655, stroke:#000000;
classDef router fill:#ffa500, stroke:#000000;

%%element
h1(H1):::host
r1(((R1))):::router
r2(((R2))):::router
h2(H2):::host


%%connectivity

h1 -- 192.168.1.0/24 --- r1
r1 -- 10.10.1.0/30 --- r2
r2 -- 192.168.2.0/24 --- h2

```

```mermaid
graph LR;
%%Colors

classDef host fill:#fffb05, stroke:#000000;
classDef switch fill:#1fd655, stroke:#000000;
classDef router fill:#ffa500, stroke:#000000;

%%element
h1(H1):::host
r1(((R1))):::router
r2(((R2))):::router
r3(((R3))):::router
h2(H2):::host

%%connectivity
h1 -- 192.168.1.0/24 --- r1
r1 -- 10.10.1.0/30 --- r2
r1 -- 10.10.2.0/30 --- r3
r3 -- 10.10.3.0/30 --- r2
r2 -- 192.168.2.0/24 --- h2

```
