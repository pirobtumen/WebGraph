/*
  Web Graph
  ==============================================================================

  Web Graph is a program that finds relationships between web pages.

  It downloads a web page, extract the urls and follow those links in order
  to generate connections between the webs.

  It's made in C++/Lex for a university project.

  Dependencies:

  Usage:

  Output:

  Visualization:

  Alberto Sola Comino - 2016
*/

%{
//------------------------------------------------------------------------------
// Definitions
//------------------------------------------------------------------------------
%}

%{

#include <iostream>
#include <stdio.h>
#include <cstring>
#include <string>
#include <vector>
#include <set>
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

std::set<std::string> urls;
unsigned int total_urls = 0;
unsigned int total_resources = 0;
unsigned int total_images = 0;
unsigned int total_web = 0;

//------------------------------------------------------------------------------

%}

schema    ((http)s?(:\/\/))
www       ((www\.)?)
name      ([a-z0-9\-\.]+)
dot       (\.)
domain    ([a-z]+)
path      \/?[a-zA-Z0-9\?\/\-\_\&\.\=\;]*
url       ({schema}{www}{name}{dot}{domain}{path})
url_res   ({url}(.js|.css){path})
url_img   ({url}(.jpg|.jpeg|.png|.gif|.ico){path})
url_web   ({url}(.html|.php|.asp)?{path})

%{
//------------------------------------------------------------------------------
// Rules
//------------------------------------------------------------------------------
%}

%%

{url_res} {
  total_resources++;
}

{url_img} {
  total_images++;
}

{url_web} {
  std::string url_str = yytext;
  urls.insert(yytext);
  total_web++;
}

%%

//------------------------------------------------------------------------------
// Functions
//------------------------------------------------------------------------------

int yywrap(void){
  /*
    Prints the total number of URLs found.
  */

  total_urls = total_web + total_images + total_resources;

  std::cout << "Different URLs: " << urls.size() << std::endl;
  std::cout << "Total URLs: " << total_urls << std::endl;

  std::cout << "Total web: " << total_web << std::endl;
  std::cout << "Total images: " << total_images << std::endl;
  std::cout << "Total resources: " << total_resources << std::endl;
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
    Downloads an URL (http) into a (FILE) stream.
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
    // TODO: exit

}

//------------------------------------------------------------------------------

int main(int argc, char ** argv){
  Stream stream;
  FILE * data = nullptr;
  std::string url = argv[1];
  char c;

  // TODO: parse args.

  stream.data = new char[4096];
  stream.size = 0;

  get_url(url,&stream);

  if(stream.data != nullptr){
    std::cout << "Stream size: " << stream.size << std::endl;

    data = fmemopen(stream.data,stream.size,"r");;
    yyin = data;
    yylex();

    #ifdef DEBUG
    for( size_t i = 0; i < stream.size; i++ )
      std::cout << stream.data[i];

    std::cout << std::endl;
    #endif

    fclose(data);
  }
  else
    std::cout << "Err." << std::endl;

  for(auto & url: urls)
    std::cout << "- " << url << std::endl;

  delete[] stream.data;
}
