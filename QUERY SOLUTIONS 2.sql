/* Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
 Display the member's_id, member's name, book title, issue date, and days overdue. */

select m.member_id, m.member_name, b.book_title,
 ist.issued_date,rst.return_date,curdate()-ist.issued_date as over_due_days from issued_status ist
join members m
on ist.issued_member_id=m.member_id
join books b on ist.issued_book_isbn=b.isbn
left join return_status rst
on rst.issued_id=ist.issued_id
where return_id is NULL 
and (curdate()-ist.issued_date) >30
order by 1;

/* Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table). */
     select * from books;
     select * from return_status;
     select * from issued_status;
delimiter $$
  create procedure  pr_return_status(in p_return_id varchar(20), in p_issued_id varchar(20))
begin
      declare v_isbn varchar(50) ;
	select issued_book_isbn into v_isbn from issued_status
    where issued_id=p_issued_id;
insert into return_status(return_id,issued_id,return_date)
values(p_return_id,p_issued_id,curdate());
update books
set status='yes'
where isbn=v_isbn;
end $$
delimiter ;
CALL pr_return_status('RS138', 'IS135');
select * from books;

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued,
the number of books returned, and the total revenue generated from book rentals. */
create table branch_report as
select b.branch_id,
COUNT(ist.issued_id) as number_book_issued,
    COUNT(rst.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue from issued_status ist
join employees e on ist.issued_emp_id=e.emp_id  
join branch b on b.branch_id=e.branch_id
left join return_status rst on rst.issued_id=ist.issued_id
join books bk on bk.isbn=ist.issued_book_isbn
group by branch_id;

/* Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members
containing members who have issued at least one book in the last 2 months. */
create table active_members as
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL 2 month
                    )
;
select * from active_members;

/* Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
 Display the employee name, number of books processed, and their branch. */
 SELECT 
    e.emp_name,
    COUNT(i.issued_id) AS books_processed,
    e.branch_id
FROM 
    employees e
JOIN 
    issued_status i ON e.emp_id = i.issued_emp_id
    group by e.emp_name,e.branch_id

ORDER BY 
    books_processed DESC
LIMIT 3;

/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books
 in a library system. Description: Write a stored procedure that updates the status
 of a book in the library based on its issuance. The procedure should function as follows: 
 The stored procedure should take the book_id as an input parameter. The procedure should first
 check if the book is available (status = 'yes'). If the book is available, it should be issued, and
 the status in the books table should be updated to 'no'. If the book is not available (status = 'no'),
 the procedure should return an error message indicating that the book is currently not available
select * from books;
select * from issued_status; */
delimiter $$
create procedure pr_books(in p_issued_id VARCHAR(10),in  p_issued_member_id VARCHAR(30),
 in p_issued_book_isbn VARCHAR(30), in p_issued_emp_id VARCHAR(10))
begin
 
 declare v_status varchar(10);
  
  select status  into v_status from books 
  where isbn=p_book_id;
 if  v_status='yes' then
 insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
 values(p_issued_id ,  p_issued_member_id,curdate(),
 p_issued_book_isbn ,p_issued_emp_id );
  update books
  set status='no'
  where isbn=p_issued_book_isbn;
 else  
  select 'Sorry to inform you the book you have requested is unavailable';
  end if;
  end $$
delimiter ;

 -- testing the function
 SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

/* TASK 20
Create Table As Select (CTAS) Objective:Create a CTAS(Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but 
not returned within 30 days. The table should include: The number of overdue books. 
The total fines, with each days fine calculated at $0.50.The number of books issued by each member. 
the resulting table should show: Member ID Number of overdue books Total fines */
 
 CREATE TABLE overdue_fines_summary AS
SELECT 
    ist.issued_member_id AS member_id,
    COUNT(CASE 
              WHEN rs.return_date IS NULL AND DATEDIFF(CURDATE(), ist.issued_date) > 30 
              THEN 1 
         END) AS overdue_books,
    SUM(CASE 
            WHEN rs.return_date IS NULL AND DATEDIFF(CURDATE(), ist.issued_date) > 30 
            THEN (DATEDIFF(CURDATE(), ist.issued_date) - 30) * 0.50 
            ELSE 0 
        END) AS total_fines,
    COUNT(*) AS total_books_issued
FROM issued_status AS ist
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
GROUP BY ist.issued_member_id;

select * from overdue_fines_summary;


SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    sum(( CURRENT_DATE - ist.issued_date)*0.5) as fine,
    
    CURRENT_DATE - ist.issued_date as over_dues_days
    
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
group BY ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date;