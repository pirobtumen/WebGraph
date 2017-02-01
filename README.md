# Web Graph

Web Graph is a program that finds relationships between web pages.

It downloads a web page, extract the urls and follow those links in order
to generate connections between the webs.

It's made with C++ and Lex for a university project.

The output can be preprocessed with 'graph.py' in order to generate a graph, but because of there is a lot of data, if you want to display the graph it would be necessary to extract the most relevant data.

Example of data from Reddit:



## Dependencies
- C++ (g++)
- flex
- libcurl
- python3

## Usage

$ make
$ ./webgraph <url> <depth>

- url: start url.
- depth: number of links to follow (depth).

## Output

TXT File where each line is:

<downloaded url> <scrapped urls>

You can run "python3 graph.py" and it will parse this output file and it will create a .csv file with the edges of a graph.

## Visualization

Soon :)
