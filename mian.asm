# Mayar Etawi  1230501 sec 1
# Heba  Dababat 1230151 Sec1 

.data
# data section -------------------------
Input_file_Name: .space 200   # user input filename
buffer: .space 1000        # file read buffer
enter_file_Name: .asciiz "Enter the input file name or path: "
welcome: .asciiz "Welcome to heba and maiar Clique Detection program :) \n"
Output_file_name: .asciiz "output.txt"
One_Clique_size: .asciiz "Clique with size one\n"
newline: .asciiz "\n"
spece:.asciiz "\t"
matrix_size_error: .asciiz "There is an error in the matix size , must be n*n ,n is maximum 5 :( \n"
# error messeges if the file cant open or there is an error in reading the file -------------------------
error_open_file: .asciiz "There is an error in opening the file , File open failure :(\n"
error_read_file: .asciiz "There is an error in reading the file , File read failure :(\n"

# Output storage------------------------------------------

Maximum_clique_size:          .space 100 #an variable to hold the max clique size found in the matix 
vertices_in_maximum_clique:   .space 100 # a space to store the subsets of the matrix that is clique 

# Exit message------------------------------------------------------

exiting: .asciiz "Exiting System \nThank you for using our system \n made with love by heba & mayar :)"

# clique detection-------------------------------------------

vertices_Num: .word 0  # a variable to store the number of vertices 
adj: .space 100   #for adjacency matrix

#Final output messeges -------------------------------

msg_max:      .asciiz "Maximum clique size: "
msg_vertices: .asciiz "Vertices in maximum clique:"

#main code ------------------------------------
.text 
.globl main

main:
    # Print welcome message
	li $v0,4 #4 is a syscall to print sting
	la $a0,welcome
    	syscall
    
    # Ask user for input file name
	la $a0,enter_file_Name
    	li $v0,4 #4 syscall to print to the user to enter the file name
    	syscall
    
    # Read filename from user
	la $a0,Input_file_Name
    	li $a1,200 #load the addresses ,the file name will be stored, max size for input 200 char
    	li $v0,8 # 8 is a syscall to read a string from user(file name)
    	syscall
    
    # Remove newline if present/input.txt/n 
	la $t0,Input_file_Name 
removenewline:
	lb $t1,0($t0) #to read one char from the string (file name)
    	beqz $t1,removenewline_done  # check if we reached the null terminator     
    	beq  $t1,10,put_null #check is the char is 10(new line in ASCI) 
    	addi $t0, $t0, 1
    	j removenewline
put_null:
	sb $zero, 0($t0) #if we reached the 10(new line) replace the new line with null terminator 
removenewline_done: 


    # Open input file
	la $a0,Input_file_Name
    	li $a1,0  #flag for read only mode            
    	li $a2,0  
    	li $v0,13  #13 is a syscall to open file for writing
    	syscall
    	move $s0,$v0        
    	bltz $s0,FILE_OPEN_ERROR

    # READ CONTENT OF FILE
   
	move $a0,$s0           
    	la   $a1,buffer        
    	li   $a2,1000 
    	li   $v0,14        
    	syscall
    
    	move $s3,$v0           
    
    # Check if read was successful
   	 blez $s3, FILE_READ_ERROR

    # Close input file
  
   	 move $a0,$s0
    	li   $v0,16
    	syscall
    
    # Open output file

    la $a0,Output_file_name
    li $a1, 1               
    li $a2, 0
    li $v0, 13
    syscall
    move $s1, $v0           
    bltz $s1, FILE_OPEN_ERROR

    # Parse buffer and fill adjacency matrix

	la $t0,buffer #points to the current position in buffer
    	la $t1,adj #points to the currecnt position in adj
    	li $t2,0          # t2 counter for number of elements stored

#this loop converts the text char from the file into interger valuse stored in the adjacency matrix 

convert_char :
    	lb  $t3,0($t0) #read a char form the buffer
	beqz $t3,done_converting  # check if we reached the end of the buffer
    
    	li $t4,'0' #else if the char is 0 then store it as 0 in adj
    	beq $t3,$t4, store_zero
    	li $t4,'1' #else if the char is 1 then store it as 1 in adj
    	beq $t3,$t4, store_one
    
    	addi $t0,$t0,1 #move to the next char
    	j convert_char

# to store the char (0) as a integer 0 
store_zero:
    	sw $zero,0($t1) #store 0 at the current position in adj
    	addi $t1,$t1,4 #move to the next pos in the adj 
    	addi $t2,$t2,1 #counter++
	addi $t0,$t0,1 #move buffer pointer to the next elemnt
    	j convert_char

# to store the char (1) as a integer 1 
store_one:  #same as store one but with small changes 
	li $t5,1 
    	sw $t5,0($t1) #store int 1 at the current position in adj
    	addi $t1,$t1,4  
    	addi $t2,$t2,1
    	addi $t0,$t0,1
    	j convert_char

done_converting :
    # Check if it read at least some elements
    	beqz $t2, FILE_READ_ERROR
    # Determine vertices_Num based on number of elements t2
    #2*2 \3*3\4*4\5*5
	move $t3, $t2   # t3 = count

    	li $t4,25 #check if the num of vertices is 5
    	beq $t3, $t4,numbervertices_5

    	li $t4,16 #check if the num of vertices is 4
    	beq $t3,$t4,numbervertices_4

    	li $t4,9 #check if the num of vertices is 3
    	beq $t3,$t4,numbervertices_3

    	li $t4,4 #check if the num of vertices is 2
    	beq $t3,$t4,numbervertices_2
    
    	li $t4,1 #check if the num of vertices is 1
    	beq $t3,$t4,numbervertices_1

    # Not a valid square size
    #else is the matrix is not n*n or n is greater than 5
    	j MATRIX_SIZE_ERROR

numbervertices_5:
    	li $t1,5
    	j Save_num_vertices

numbervertices_4:
    	li $t1,4
    	j Save_num_vertices

numbervertices_3:
    	li $t1,3
    	j Save_num_vertices

numbervertices_2:
    	li $t1,2
     	j Save_num_vertices
     	
     
numbervertices_1:  #if the num of vertices is 1 :
	li $v0,4 #4 is a syscall to print a meessege (clique with one size)
    	la $a0,One_Clique_size 
    	syscall
    	
    	la $a1 ,One_Clique_size
    	li $a2,20 #num of bytes to write 
    	move $a0,$s1 
    	li $v0,15   #20 is a syscall to write in a file 
    	syscall 
    	j EXIT
    
    
Save_num_vertices:
    	la $t0, vertices_Num
    	sw $t1, 0($t0)

# Brute force clique detection using bitmask-----------------------------


	la $s2,adj # base address of adjacency matrix

    	la $t0,vertices_Num   #load n (num of vertices ) from memo
    	lw $t1,0($t0) #t1 has the num of vertices t1=n

	#here we found the max mask which is 2^num of vertices 
        li $t2,1 
    	sllv $t4,$t2,$t1  #calc 2^n , total number of subsets

    	li $t5,0 #to track the largest clique found (size)
    	li $t6,0  #stores the vertices from the max clique(as a bitmask)

    	li $t2,1  # current mask

#here we started a loop through all subsets being tested , from 1 to 2^n

MaskLoop: 
    	beq $t2,$t4,Mask_done #check if we reached the last mask 2^n

    # Count number of bits in mask t2->t8
	move $t7,$t2
    	li   $t8,0 
 #This loop is to check if the bit is 1 in the bit mask if its 1 add the counter
 #so it counts how many vertices in the subset(mask)
Bits_check_loop: 
    	beqz $t7,Bit_check_done  #check if we reached the null ter
    	andi $t9,$t7,1  #check if the last bit is 0 or 1
    	addu $t8,$t8,$t9 #add this bit to the counter
    	srl  $t7,$t7,1 #remove the lowest bit and move to the next bit
    	j Bits_check_loop
    	
Bit_check_done:

    #if the current subset has size smaller or equal to the best clique we already found skip it
    	ble $t8,$t5,NextMask

    	li $t9,1  #bollean flag to check if a subset is a clique (if clique =1 else 0)
    	li $a2,0  #i = 0 to n-1

#this loop check for each vertex i  in the subset 
outer_loop:
	#check if we finished all the vertices
    	beq  $a2,$t1,outer_loop_done #a2 is for all vertices i in the subset


    #check if a vertix is included in the subset
    	srlv $a0,$t2,$a2  
    	andi $a0,$a0,1 #if yes a0 is 1 else its not in the subset
    	beqz $a0,inner_loop_done

    	addi $a3,$a2,1   # j = i+1
    	
  #this loop will check all vertices < i that are in the subset and verifiy if vertix i is connected to vertix j in the adj matrix
  
inner_loop:
	beq  $a3,$t1,inner_loop_done #check if j=n done

    	srlv $v1,$t2,$a3
    	andi $v1,$v1,1
    	beqz $v1,Inner_repeat
   #memory offset of a 2D array =((i*n)+j)*4
    	mul  $v0,$a2,$t1     #t1 =N and a2=i
    	addu $v0,$v0,$a3 #a3=j
    	sll  $v0,$v0,2  #mul with 4 
    	addu $v0,$s2,$v0   # $v0 =memory address,$s2 =base of adjacency matrix
    	lw   $v0,0($v0) 
    	beqz $v0,edge_check #if v0 is 1 edge exist else no

Inner_repeat:
	addi $a3,$a3,1 #j=j+1
    	j inner_loop

inner_loop_done:
    	addi $a2,$a2,1 #i=i+1
    	j outer_loop

edge_check:
    	li  $t9,0 #reset clear flag to 0
    	
outer_loop_done:
    beqz $t9,NextMask

    # Update max clique
    move $t5,$t8  #update max clique size
    move $t6,$t2  #update max clique bit mask

NextMask:
    addi $t2, $t2,1   #move to the next subset mask
    j  MaskLoop

Mask_done:

    # Print results to console-----------------------------------------------

   
    la   $a0, msg_max
    li   $v0, 4
    syscall
    
    move $a0, $t5
    li   $v0, 1
    syscall
    
    la   $a0, newline
    li   $v0, 4
    syscall

    la   $a0, msg_vertices
    li   $v0, 4
    syscall

    li   $t0, 0
    la   $t2, vertices_Num
    lw   $t1, 0($t2)      # t1 = N
PrintVerts:
    beq  $t0, $t1, PV_Done
    srlv $t7, $t6, $t0
    andi $t7, $t7, 1
    beqz $t7, PV_Next
    
    li   $v0, 11
    li   $a0, 32          # space
    syscall
    
    li   $v0, 1
    move $a0, $t0
    syscall
    
PV_Next:
    addi $t0, $t0, 1
    j    PrintVerts
PV_Done:
    li   $v0, 4
    la   $a0, newline
    syscall
    
    #---------------------------
# WRITE RESULTS TO output.txt  (file descriptor = $s1)
#-----------------------------------

# --- Write "Maximum clique size: " ---
li $v0, 15
move $a0, $s1
la $a1, msg_max
li $a2, 22                # length of text "Maximum clique size: "
syscall

# --- Write the number (t5) ---
# Convert integer to string manually
# buffer used as temp
la $t0, buffer
move $t1, $t5
li $t2, 0

int_to_str_loop:
    beqz $t1, int_to_str_done
    li $t3, 10
    div $t1, $t3
    mfhi $t4
    mflo $t1
    addi $t4, $t4, 48
    sb $t4, 0($t0)
    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j int_to_str_loop

int_to_str_done:
# reverse string
la $a0, buffer
addi $a1, $a0, 0
addi $a1, $a1, -1
add $a1, $a1, $t2

rev_loop:
    blt $a1, $a0, rev_done
    lb $t3, 0($a0)
    lb $t4, 0($a1)
    sb $t4, 0($a0)
    sb $t3, 0($a1)
    addi $a0, $a0, 1
    addi $a1, $a1, -1
    j rev_loop

rev_done:

# write number to file

move $a0, $s1
la $a1, buffer
move $a2, $t2
li $v0, 15
syscall

# write newline

move $a0, $s1
la $a1, newline
li $a2, 1
li $v0, 15
syscall


#--------------------------------------------
# Write vertices list
#----------------------------------------------

# --- Write label "Vertices in maximum clique:" ---

move $a0, $s1
la $a1, msg_vertices
li $a2, 31
li $v0, 15
syscall

# spece 

move $a0, $s1
la $a1, spece
li $a2, 1
li $v0, 15
syscall

# --- Write vertices numbers ---
li $t0, 0
la $t2, vertices_Num
lw $t1, 0($t2)      # t1 = N

WriteVertsFile:
    beq $t0, $t1, WV_end

    srlv $t7, $t6, $t0
    andi $t7, $t7, 1
    beqz $t7, WV_next

    # write newline 
   
    move $a0, $s1
    la $a1, spece
    li $a2, 1
     li $v0, 15
    syscall

    # convert vertex number (t0) to ASCII
    addi $t8, $t0, 48
    sb $t8, buffer

    # write vertex number
    li $v0, 15
    move $a0, $s1
    la $a1, buffer
    li $a2, 1
    syscall

WV_next:
    addi $t0, $t0, 1
    j WriteVertsFile

WV_end:
# newline
li $v0, 15
move $a0, $s1
la $a1, newline
li $a2, 1
syscall


    #------------------------------------
    # Close output file
    #---------------------------------
    li   $v0, 16
    move $a0, $s1
    syscall

    # Print exiting message
    li $v0, 4
    la $a0, exiting
    syscall
    
    # Exit program
    li $v0, 10
    syscall

# ==========================================================
# FUNCTIONS
# ==========================================================
open_file:
    li $v0, 13
    syscall
    jr $ra

# ==========================================================
# ERROR HANDLING
# ==========================================================
FILE_OPEN_ERROR:
    li $v0, 4
    la $a0, error_open_file
    syscall
    j EXIT

FILE_READ_ERROR:
    li $v0, 4
    la $a0, error_read_file
    syscall
    j EXIT
    
MATRIX_SIZE_ERROR:
    li $v0, 4
    la $a0, matrix_size_error
    syscall
    j EXIT
    
# EXIT -----------------------------------------------------------
EXIT:
    li $v0, 4
    la $a0, exiting
    syscall
    li $v0, 10
    syscall
