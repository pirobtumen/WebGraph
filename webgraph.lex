/*
  Web Graph
  ==============================================================================

  Web Graph is a program that finds relationships between web pages.

  It downloads a web page, extract the urls and follow those links in order
  to generate connections between the webs.

  It's made with C++ and Lex for a university project.

  Dependencies:
    - libcurl
    - flex

  Usage:
    - make
    - ./webgraph <url> <depth>

  Output: TXT File
  Each line: <downloaded url> <scrapped urls>
	
  LICENSE:  MIT
  AUTHOR:   Alberto Sola, 2016 - 2017
*/

%{
//------------------------------------------------------------------------------
// Definitions
//------------------------------------------------------------------------------
%}

%{

#include <iostream>
#include <fstream>
#include <stdio.h>
#include <cstring>
#include <string>
#include <vector>
#include <set>
#include <queue>
#include <curl/curl.h>

extern "C"{
  int yylex();
}

//------------------------------------------------------------------------------

struct Stream{
  char * data;
  size_t size;
};

//------------------------------------------------------------------------------

const char URL_SEPARATOR = ' ';

std::ofstream output("data.txt");
std::queue<std::string> url_queue;
std::set<std::string> visited_urls;
std::set<std::string> urls;

unsigned int total_urls = 0;
unsigned int total_resources = 0;
unsigned int total_images = 0;
unsigned int total_web = 0;

unsigned int num_urls = 0;
unsigned int num_resources = 0;
unsigned int num_images = 0;
unsigned int num_web = 0;

unsigned int current_depth = 1;
unsigned int max_depth = 1;         // User input

unsigned int depth_limit = 1;       // There is at least one URL
unsigned int next_depth_limit = 0;

unsigned int depth_count = 0;
unsigned int count = 0;

//------------------------------------------------------------------------------

%}

schema    ((http)s?(:\/\/))
www       ((www\.)?)
name      ([a-z0-9\-\.]+)
dot       (\.)
domain    ([a-z]+)
path      (\/?[a-zA-Z0-9\?\/\-\_\&\.\=\;]*)
url       ({schema}{www}{name}{dot}{domain}{path}?)
url_res   ({url}(.js|.css|.json|.xml){path}?)
url_img   ({url}(.jpg|.jpeg|.png|.gif|.ico){path}?)
url_web   ({url}(.html|.php|.asp)?{path}?)

%{
//------------------------------------------------------------------------------
// Rules
//------------------------------------------------------------------------------
%}

%%

{url_res} {
  output << yytext;
  output << URL_SEPARATOR;
  num_resources++;
}

{url_img} {
  output << yytext;
  output << URL_SEPARATOR;
  num_images++;
}

{url_web} {
  std::string url_str = yytext;

  // URLs found
  urls.insert(yytext);

  output << url_str;
  output << URL_SEPARATOR;

  num_web++;
}

%%

//------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------

int yywrap(void){
  /*
    Prints the total number of URLs found.
  */

  num_urls = num_web + num_images + num_resources;

  std::cout << "Total URLs: \t\t" << num_urls << std::endl;
  std::cout << "Different/Total web: \t" << urls.size() << "/" << num_web << std::endl;
  std::cout << "Total images: \t\t" << num_images << std::endl;
  std::cout << "Total resources: \t" << num_resources << std::endl;

}

//------------------------------------------------------------------------------

size_t write_data(void *buffer, size_t size, size_t nmemb, Stream * stream){
  /*
    Create a stream (FILE) for the buffer.
    Returns the buffer size.
  */

  size_t index = stream->size;
  size_t buff_size = size * nmemb;

  #ifdef DEBUG
  std::cout << "Package: " << buff_size << std::endl;
  #endif

  stream->size += buff_size;

  // Increase buffer capacity
  stream->data = (char*)realloc(stream->data,stream->size);

  // Copy the new data
  memcpy( (stream->data+index),buffer,buff_size);

  return buff_size;
}

//------------------------------------------------------------------------------

void get_url(const std::string & url, Stream * stream){
  /*
    Downloads an URL (http) into a Stream ( char[] ).
  */
  CURL * curl;

  curl_global_init(CURL_GLOBAL_ALL);
  curl = curl_easy_init();

  if(curl){
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, stream);
    curl_easy_perform(curl);
    curl_easy_cleanup(curl);
  }
  else
    std::cout << "Can't initialize CURL..." << std::endl;

}

//------------------------------------------------------------------------------

void scrap_url(const std::string & url){
  /*
    Scraps an URL. It extracts all the URLs and it adds those URLs to a
    container in order to continue exploring new levels while depth > 0.
  */
  Stream stream;
  FILE * data = nullptr;
  char c;

  stream.data = new char[4096];
  stream.size = 0;

  // Download URL
  get_url(url,&stream);

  if(stream.data != nullptr){
    // Show stream size
    std::cout << "Stream size: \t\t" << stream.size << std::endl;

    // Open stream in memory
    data = fmemopen(stream.data, stream.size,"r");;

    // Change LEX input
    yyin = data;

    // Parse stream
    yylex();

    // Free memory
    fclose(data);

    // Debug stream
    // -------------------------------------------------------------------------
    #ifdef DEBUG
    for( size_t i = 0; i < stream.size; i++ )
      std::cout << stream.data[i];

    std::cout << std::endl;
    #endif
    // -------------------------------------------------------------------------

  }
  else
    std::cout << "Error: Empty stream." << std::endl;

  // Free Stream array
  delete[] stream.data;
}

//------------------------------------------------------------------------------

void scrap_levels(const std::string & start_url){
  std::set<std::string>::iterator element;
  std::string url = start_url;

  // Add the first URL
  url_queue.push(url);

  // Download and scrap url
  while(!url_queue.empty()){

    // Update
    count += 1;
    depth_count += 1;

    std::cout << "Total/Queue: \t\t"<< count << "/" << url_queue.size() << std::endl;

    // Get next URL
    url = url_queue.front();
    url_queue.pop();

    // Write it to the file
    output << url;
    output << URL_SEPARATOR;

    std::cout << "URL: \t\t\t" << url << std::endl;

    // Mark it
    visited_urls.insert(url);

    // Scrap
    scrap_url(url);

    std::cout << "-------------------------------------------------";
    std::cout << std::endl << std::endl;

    // While i'm not in the depth limit
    if( current_depth < max_depth ){

      // Add the next URLs to download
      for( auto & url : urls ){

        // Only if it hasn't been visited
        element = visited_urls.find(yytext);

        if(element == visited_urls.end()){
          url_queue.push(url);
          next_depth_limit++;   // Update next depth limit
        }
      }

      // Check the depth
      if( depth_count == depth_limit ){
        current_depth++;
        depth_limit = next_depth_limit;
        next_depth_limit = 0;
        depth_count = 0;
      }

    }

    // End output line
    output << std::endl;

    // Update stats
    // -------------------------------------------------------------------------

    total_web += num_web;
    total_images += num_images;
    total_resources += num_resources;
    total_urls += num_urls;

    // Reset stats
    // -------------------------------------------------------------------------

    num_urls = 0;
    num_web = 0;
    num_images = 0;
    num_resources = 0;

    // Save data and reset
    // -------------------------------------------------------------------------
    urls.clear();
  }


  // Global stats
  // ---------------------------------------------------------------------------

  std::cout << "-------------------------------------------------" << std::endl;
  std::cout << "Global stats" << std::endl;
  std::cout << "-------------------------------------------------" << std::endl;
  std::cout << "Total URLs: \t" << total_urls << std::endl;
  std::cout << "Total web: \t" << total_web << std::endl;
  std::cout << "Total images: \t" << total_images << std::endl;
  std::cout << "Total resources: " << total_resources << std::endl;
}

//------------------------------------------------------------------------------

int main(int argc, char ** argv){

  if(argc != 3){
    //TODO: print help
    exit(-1);
  }
  else
    max_depth = std::atoi(argv[2]);

  scrap_levels(argv[1]);

  output.close();
}
