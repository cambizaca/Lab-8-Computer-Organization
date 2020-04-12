#include<stdio.h>

int NchooseK(int n,int k);

int main() {

  int n;
  int k;

  while(1) {
   scanf("%d %d", &n, &k);
   if(n == 0) {
     return 0;
    } else {
      printf("%d\n",NchooseK(n,k));
    }
  }
}

int NchooseK(int n, int k) {
  if(n == 0) {
    return 1;
  } else if (n > k && k > 0){
     return  NchooseK(n-1, k) + NchooseK(n-1, k-1);
  } else {
    return 1;
  }
}
