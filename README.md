# Web Graph

Web Graph is a program that finds relationships between web pages.

It downloads a web page, extract the urls and follow those links in order
to generate connections between the webs.

It's made in C++/Lex for a university project.

## Dependencies
- C++ (g++)
- flex
- libcurl

## Usage

$ make
$ ./webgraph <url>

- level: number of links to follow (depth).
- url: start url.

Example:
$ ./webgraph http://www.google.com

## Output

## Visualization
