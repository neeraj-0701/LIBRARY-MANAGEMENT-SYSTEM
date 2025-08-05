select * from branch;
select * from members;
select * from books;
select * from employees;
select * from issued_status;
select * from return_status;

 -- PROJECT TASK
 /* Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 
 -- 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')" */
 
 INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
 VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
update members
set member_address='125 Oak St'
where member_id='C101';

/*Task 3: Delete a Record from the Issued Status Table --
 Objective: Delete the record with issued_id = 'IS121' from the issued_status table. */

DELETE FROM issued_status 
WHERE issued_id='IS121'

/* Task 4: Retrieve All Books Issued by a Specific Employee 
Objective: Select all books issued by the employee with emp_id = 'E101' */ 
 
select * FROM issued_status where issued_emp_id='E101';

/*Task 5: List Members Who Have Issued More Than One Book */
select issued_member_id,count(issued_id) from issued_status
group by issued_member_id
having count(issued_id)>1;

/*Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
each book and total book_issued_cnt */

select b.isbn,count(ist.issued_id) from books b 
join issued_status ist 
on b.isbn=ist.issued_book_isbn
group by b.isbn;

-- Task 7 .Retrieve All Books in a Specific Category:
select * from books where category='fantasy';

-- Task 8: Find Total Rental Income by Category:
select b.category,sum(rental_price)from books b
join
issued_status istt on
b.isbn=istt.issued_book_isbn
group by category;

-- TASK 9.List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- TASK-10 List Employees with Their Branch Manager's Name and their branch details:
SELECT e1.emp_name,e2.emp_name as manager ,b.* FROM EMPLOYEES E1 JOIN 
branch b 
ON e1.branch_id=b.branch_id
join 
employees e2 
on b.manager_id=e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
select * from expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned
select ist.* from issued_status as ist 
left join return_status rst 
on ist.issued_id=rst.issued_id
where rst.issued_id is NULL;




