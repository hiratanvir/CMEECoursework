#print hello up until 10 seconds using proc.time

print_hello <- function(){
  while(proc.time()[3] < 12800){
    print('hello')
  }
}