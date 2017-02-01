# Web Graph

Web Graph is a program that finds relationships between web pages.

It downloads a web page, extract the urls and follow those links in order
to generate connections between the webs.

It's made with C++ and Lex for a university project.

## Dependencies
- C++ (g++)
- flex
- libcurl

## Usage

$ make
$ ./webgraph <url> <depth>

- url: start url.
- depth: number of links to follow (depth).

## Output

TXT File where each line is:

<downloaded url> <scrapped urls>

## Visualization

Soon :)
