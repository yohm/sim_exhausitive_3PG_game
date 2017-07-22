// three-player public-goods game
// 2017. 5. 14.
#include <stdio.h>
#include <stdlib.h>
#define DEBUG 1

// 2^n
long pow2(int n)
{
   int i;
   long p = 1;
   for(i=0; i<n; i++) p = p << 1;
   return p;
}

void str2bit(long str, int* bit, int n)
{
   int i;
   for(i=0; i<n; i++){
      bit[i] = (str>>i) & 1;
   }
}

void state2bit(int state, int* bit, int n)
{
   int i;
   for(i=0; i<n; i++){
      bit[i] = (state>>(n-1-i)) & 1;
   }
}

// transition in the presence of error
int transition(int currentstate1, int* strbit1, int* strbit2, int* strbit3, int m, int correct1, int correct2, int correct3)
{
   int history1; // player1's history
   int history2; // player2's history
   int history3; // player3's history
   int state1;  // state from player 1's viewpoint
   int state2;  // state from player 2's viewpoint
   int state3;  // state from player 3's viewpoint
   int move1;
   int move2;
   int move3;
   int newhistory1;
   int newhistory2;
   int newhistory3;
   int newstate1;
   int newstate2;
   int newstate3;

   int mask = pow2(m)-1;
   int submask = pow2(m-1)-1;

   history1 = currentstate1 >> (2*m);        // a_{t-2}, a_{t-1}
   history2 = (currentstate1 >> m) & mask;   // b_{t-2}, b_{t-1}
   history3 = currentstate1 & mask;          // c_{t-2}, c_{t-1}

   state1 = (history1 << (2*m)) + (history2 << m) + history3; //a2a1 b2b1 c2c1
   state2 = (history2 << (2*m)) + (history3 << m) + history1; //b2b1 c2c1 a2a1
   state3 = (history3 << (2*m)) + (history1 << m) + history2; //c2c1 a2a1 b2b1

   move1 = correct1 ? strbit1[state1] : !strbit1[state1];
   move2 = correct2 ? strbit2[state2] : !strbit2[state2];
   move3 = correct3 ? strbit3[state3] : !strbit3[state3];

   newhistory1 = ((history1 & submask)<<1) + move1;   // a_{t-1}, a_{t-0}
   newhistory2 = ((history2 & submask)<<1) + move2;   // b_{t-1}, b_{t-0}
   newhistory3 = ((history3 & submask)<<1) + move3;   // c_{t-1}, c_{t-0}

   newstate1 = (newhistory1 << (2*m)) + (newhistory2 << m) + newhistory3;
   newstate2 = (newhistory2 << (2*m)) + (newhistory3 << m) + newhistory1;
   newstate3 = (newhistory3 << (2*m)) + (newhistory1 << m) + newhistory2;

   return newstate1;
}

void test(long str1, long str2, long str3, int m)
{
   int i, j;
   int n = pow2(3*m); // total number of bits in a strategy
   int strbit1[n]; // bitwise representation of str1
   int strbit2[n]; // bitwise representation of str2
   int strbit3[n]; // bitwise representation of str3

   int history1; // player1's history
   int history2; // player2's history
   int history3; // player3's history
   int state1;  // state from player 1's viewpoint
   int state2;  // state from player 2's viewpoint
   int state3;  // state from player 3's viewpoint
   int statebit1[n]; // bitwise representation of state1
   int statebit2[n]; // bitwise representation of state2
   int statebit3[n]; // bitwise representation of state3

   int newhistory1;
   int newhistory2;
   int newhistory3;
   int newstate1;
   int newstate2;
   int newstate3;
   int newstatebit1[n];
   int newstatebit2[n];
   int newstatebit3[n];

   int mask = pow2(m)-1;
   int submask = pow2(m-1)-1;

   for(i=0; i<n; i++){
      str2bit(str1, strbit1, n);
      str2bit(str2, strbit2, n);
      str2bit(str3, strbit3, n);
   }

   printf("state1\tmove1\tstate1\tmove1\tstate3\tmove3\tnext state1\n");
   for(i=0; i<n; i++){
      history1 = i >> (2*m);
      history2 = (i >> m) & mask;
      history3 = i & mask;

      state1 = (history1 << (2*m)) + (history2 << m) + history3;
      state2 = (history2 << (2*m)) + (history3 << m) + history1;
      state3 = (history3 << (2*m)) + (history1 << m) + history2;
      state2bit(state1, statebit1, 3*m);
      state2bit(state2, statebit2, 3*m);
      state2bit(state3, statebit3, 3*m);

      newhistory1 = ((history1 & submask)<<1) + strbit1[state1];
      newhistory2 = ((history2 & submask)<<1) + strbit2[state2];
      newhistory3 = ((history3 & submask)<<1) + strbit3[state3];

      newstate1 = (newhistory1 << (2*m)) + (newhistory2 << m) + newhistory3;
      newstate2 = (newhistory2 << (2*m)) + (newhistory3 << m) + newhistory1;
      newstate3 = (newhistory3 << (2*m)) + (newhistory1 << m) + newhistory2;
      state2bit(newstate1, newstatebit1, 3*m);
      state2bit(newstate2, newstatebit2, 3*m);
      state2bit(newstate3, newstatebit3, 3*m);

      for(j=0; j<3*m; j++) printf("%d", statebit1[j]);
      printf("(%2d)\t", state1);
      printf(" %d\t", strbit1[state1]);
      for(j=0; j<3*m; j++) printf("%d", statebit2[j]);
      printf("(%2d)\t", state2);
      printf(" %d\t", strbit2[state2]);
      for(j=0; j<3*m; j++) printf("%d", statebit3[j]);
      printf("(%2d)\t", state3);
      printf(" %d\t", strbit3[state3]);
      for(j=0; j<3*m; j++) printf("%d", newstatebit1[j]);
      printf("(%2d)\t", newstate1);
      printf(" \t", strbit1[newstate1]);
      for(j=0; j<3*m; j++) printf("", newstatebit2[j]);
      printf(" \t", strbit2[newstate2]);
      for(j=0; j<3*m; j++) printf("", newstatebit3[j]);
      printf(" \n", strbit3[newstate3]);
   }
}

int main(int argc, char** argv)
{
   if(argc<8){
      printf("./mat str1 str2 str3 r c e start\n");
      exit(0);
   }

   // three strategies
   long str1 = atoi(argv[1]);
   long str2 = atoi(argv[2]);
   long str3 = atoi(argv[3]);
   double r = atof(argv[4]); // mutliplication factor
   double c = atof(argv[5]); // cost of cooperation
   double e = atof(argv[6]); // error probability
   int start = atoi(argv[7]); // starting node, irrelevant if e>0

   int i, j;
   int m = 2;   // memory length
   int n = pow2(3*m); // total number of bits in a strategy
   int strbit1[n]; // bitwise representation of str1
   int strbit2[n]; // bitwise representation of str2
   int strbit3[n]; // bitwise representation of str3
   int mask;

   double mat[n][n];
   double vec[n];
   double tem[n];
   double total;
   int count;

   double payoff1[n];
   double payoff2[n];
   double payoff3[n];
   int last1, last2, last3;
   double expected1;
   double expected2;
   double expected3;

   for(i=0; i<n; i++){
      str2bit(str1, strbit1, n);
      str2bit(str2, strbit2, n);
      str2bit(str3, strbit3, n);
   }

   if(DEBUG) test(str1, str2, str3, m);

   if(DEBUG){
      printf("Eigenvectors[{");
      for(i=0; i<n; i++){
         printf("{");
         for(j=0; j<n; j++){
            if(i==transition(j, strbit1, strbit2, strbit3, m, 1, 1, 1)){
               printf("(1-e)^3");
            }
            else printf("0");
            if(i==transition(j, strbit1, strbit2, strbit3, m, 1, 1, 0) ||
               i==transition(j, strbit1, strbit2, strbit3, m, 0, 1, 1) ||
               i==transition(j, strbit1, strbit2, strbit3, m, 1, 0, 1)){
               printf("+e*(1-e)^2");
            }
            if(i==transition(j, strbit1, strbit2, strbit3, m, 1, 0, 0) ||
               i==transition(j, strbit1, strbit2, strbit3, m, 0, 1, 0) ||
               i==transition(j, strbit1, strbit2, strbit3, m, 0, 0, 1)){
               printf("+e^2*(1-e)");
            }
            if(i==transition(j, strbit1, strbit2, strbit3, m, 0, 0, 0)){
               printf("+e^3");
            }
            if(j<n-1) printf(",");
         }
         printf("}");
         if(i<n-1) printf(",\n");
      }
      printf("}]\n");
   }

   for(i=0; i<n; i++) for(j=0; j<n; j++) mat[i][j] = 0.0;
   for(i=0; i<n; i++){
      for(j=0; j<n; j++){
         if(i==transition(j, strbit1, strbit2, strbit3, m, 1, 1, 1)){
            mat[i][j] += (1-e)*(1-e)*(1-e);
         }
         if(i==transition(j, strbit1, strbit2, strbit3, m, 1, 1, 0) ||
            i==transition(j, strbit1, strbit2, strbit3, m, 1, 0, 1) ||
            i==transition(j, strbit1, strbit2, strbit3, m, 0, 1, 1)){
            mat[i][j] += e*(1-e)*(1-e);
         }
         if(i==transition(j, strbit1, strbit2, strbit3, m, 1, 0, 0) ||
            i==transition(j, strbit1, strbit2, strbit3, m, 0, 1, 0) ||
            i==transition(j, strbit1, strbit2, strbit3, m, 0, 0, 1)){
            mat[i][j] += e*e*(1-e);
         }
         if(i==transition(j, strbit1, strbit2, strbit3, m, 0, 0, 0)){
            mat[i][j] += e*e*e;
         }
      }
   }
   if(DEBUG){
      for(i=0; i<n; i++){
         for(j=0; j<n; j++){
            printf("%.2f ", mat[i][j]);
         }
         printf("\n");
      }
   }

   for(i=0; i<n; i++){
      mask = 1;
      last1 = (i >> 2*m) & mask;
      last2 = (i >> m) & mask;
      last3 = i & mask;
      if(last1==0 && last2==0 && last3==0) payoff1[i] = r*0*c/3.0;
      if(last1==0 && last2==1 && last3==0) payoff1[i] = r*1*c/3.0;
      if(last1==1 && last2==0 && last3==0) payoff1[i] = r*1*c/3.0-c;
      if(last1==1 && last2==1 && last3==0) payoff1[i] = r*2*c/3.0-c;
      if(last1==0 && last2==0 && last3==1) payoff1[i] = r*1*c/3.0;
      if(last1==0 && last2==1 && last3==1) payoff1[i] = r*2*c/3.0;
      if(last1==1 && last2==0 && last3==1) payoff1[i] = r*2*c/3.0-c;
      if(last1==1 && last2==1 && last3==1) payoff1[i] = r*3*c/3.0-c;

      if(last1==0 && last2==0 && last3==0) payoff2[i] = r*0*c/3.0;
      if(last1==0 && last2==1 && last3==0) payoff2[i] = r*1*c/3.0-c;
      if(last1==1 && last2==0 && last3==0) payoff2[i] = r*1*c/3.0;
      if(last1==1 && last2==1 && last3==0) payoff2[i] = r*2*c/3.0-c;
      if(last1==0 && last2==0 && last3==1) payoff2[i] = r*1*c/3.0;
      if(last1==0 && last2==1 && last3==1) payoff2[i] = r*2*c/3.0-c;
      if(last1==1 && last2==0 && last3==1) payoff2[i] = r*2*c/3.0;
      if(last1==1 && last2==1 && last3==1) payoff2[i] = r*3*c/3.0-c;

      if(last1==0 && last2==0 && last3==0) payoff3[i] = r*0*c/3.0;
      if(last1==0 && last2==1 && last3==0) payoff3[i] = r*1*c/3.0;
      if(last1==1 && last2==0 && last3==0) payoff3[i] = r*1*c/3.0;
      if(last1==1 && last2==1 && last3==0) payoff3[i] = r*2*c/3.0;
      if(last1==0 && last2==0 && last3==1) payoff3[i] = r*1*c/3.0-c;
      if(last1==0 && last2==1 && last3==1) payoff3[i] = r*2*c/3.0-c;
      if(last1==1 && last2==0 && last3==1) payoff3[i] = r*2*c/3.0-c;
      if(last1==1 && last2==1 && last3==1) payoff3[i] = r*3*c/3.0-c;
   }

   // matrix multiplication by the power method
   for(i=0; i<n; i++) vec[i] = 0.0;
   vec[start] = 1.0;

   count = 0;
   expected1 = 0.0;
   expected2 = 0.0;
   expected3 = 0.0;
   while(1){
      for(i=0; i<n; i++){
         tem[i] = 0.0;
         for(j=0; j<n; j++){
            tem[i] += mat[i][j]*vec[j];
         }
      }
      total = 0.0;
      for(i=0; i<n; i++) total += tem[i];
      for(i=0; i<n; i++) vec[i] = tem[i] / total;
      count++;
      if(count == pow2(11)) break;
      if(count >= pow2(10)){
         for(i=0; i<n; i++) expected1 += vec[i]*payoff1[i];
         for(i=0; i<n; i++) expected2 += vec[i]*payoff2[i];
         for(i=0; i<n; i++) expected3 += vec[i]*payoff3[i];
      }
   }

   expected1 /= pow2(10);
   expected2 /= pow2(10);
   expected3 /= pow2(10);
   printf("%d %d %d %f %f %f\n", str1, str2, str3, expected1, expected2, expected3);

   return 1;
}
