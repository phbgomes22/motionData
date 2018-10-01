#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <vector>
#include <map>
#include <climits>
#include <functional>
#include <unistd.h>
#include <time.h>

using namespace std;

int multiply(double x) {

  return (int)(x*50 + 49/50);
}

int main() {

  ifstream file("entrada.txt");
  istream_iterator<double> start(file), end;
  vector<double> vectorIn(start, end);

  vector<int> vec2(vectorIn.size());

  cout << "NUMERO: ";
  int numero;
  cin >> numero;

  double sum = 0;
  for(int i = 0; i < vectorIn.size(); i++){
    sum += vectorIn[i];
    vectorIn[i] = sum;
  }

    for(auto const& x : vectorIn){
      cout << x << "\n";
    }

  std::transform(vectorIn.begin(), vectorIn.end(), vec2.begin(),
                 multiply);

  ofstream out;
  out.open("labels.txt", std::ios::app);

  int exercise = 2;
  int turn = 0;

  for(auto const& x : vec2){

    if(turn == 0){
      out << numero << " 1 " << exercise << " " << x;
      if(exercise == 2){
        exercise = 1;
      }
      else{
        exercise = 2;
      }

      turn = 1;
    }

    else{
      out << " " << x << "\n";
      turn = 0;
    }
  }
}

//g++ -Wall -std=c++11 -stdlib=libc++ -o script script.cpp
