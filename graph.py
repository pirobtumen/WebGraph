from urllib.parse import urlparse


if __name__ == '__main__':
    data = open("data.txt", "r").readlines()
    output = open("edges.csv","w")

    for line in data:
        url_list = line.split(" ")
        first_url = urlparse(url_list[0]).netloc

        for url in url_list[1:]:
            url_parse = urlparse(url).netloc
            if first_url != url_parse:
                output.write(first_url)
                output.write(",")
                output.write(url_parse)
                output.write('\n')

    output.close()
