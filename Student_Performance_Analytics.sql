create database Student_Performance_Analytics;
use Student_Performance_Analytics;

select * from student_scores;
select * from students;
select * from subjects;
select * from classes;
select * from teachers;
# Q: Show subjects with average score less than 65.

select subject_id, subject_name
from subjects
where subject_id in (select subject_id
                    from student_scores
                    group by subject_id
                    having avg(score)<65);

# Q: Categorize scores into 'Pass' or 'Fail'
select score,
case 
  when score<35 then "Fail"
  else "Pass"
end as "Pass/Fail" 
from student_scores;

# Q: List students who scored above the average score of all tests.

select name
from students
where student_id in     (select student_id
                       from student_scores
                        where score >= (select avg(score)
			                             from student_scores));

select * from student_scores;
select * from students;
select * from subjects;
select * from classes;
select * from teachers;

# Q: Get all test types that are either Midterm or Final
select student_id, test_type
from student_scores
where test_type ="Midterm" or test_type ="Final";

# Q1: Rank students based on score
select score, 
rank() over(order by score asc) as "rank"
from student_scores;

# Q: Find number of days between test date and current date.
select test_date,
datediff(curdate(), test_date) as "days"
from student_scores;

# Q: Update all test scores below 30 to 35 (pass marks).
update student_scores
set score =35
where score <30;

#Q: Delete tests where test_type = 'Practice'.

delete from student_scores
where test_type="Practice";

#Q2: Compare each score with previous score (LAG)
select score, 
lag(score) over (partition by score order by score) as "lag"
from student_scores;

# Q3: Get first test date per student
select test_date,
first_value(test_date) over (partition by student_id order by test_date) as "first"
from student_scores;

#Q. Add a column for extra_credit
alter table student_scores
add column extra_credit varchar(50);

#Q. Modify column (change score to FLOAT)

alter table student_scores
modify column score float;

#Q: For each test, calculate the total score as score + 5 bonus marks, and scaled score as score * 1.1

select score, score +5 as "total_score", score*1.1 as "scaled score"
from student_scores;

#Q: Get all test records where students scored more than 90 marks, sorted by score descending.

select *
from student_scores
where score >90 
order by score desc;

#Q: Find the average score per subject and names of subjects.

select subject_name
from subjects
where subject_id  in (select subject_id, avg(score) as "avg"
                           from student_scores
						   group by subject_id);

SELECT s.subject_name, t.avg_score
FROM subjects  as s
JOIN (
    SELECT subject_id, AVG(score) AS avg_score
    FROM student_scores as t
    GROUP BY subject_id
) t  ON s.subject_id = t.subject_id;

select month (test_date) as "month"
from student_scores;

select * from student_scores;
select * from students;
select * from subjects;
select * from classes;
select * from teachers;

# Q1. Add Internal Bonus: score + 5 for each student

select student_id, sum(score + 5) as "Internal Bonus"
from student_scores
group by student_id;

select student_id, (score + 5) as "Internal Bonus"
from student_scores;

# Q2. Markup Score by 10% (Multiplication)
select (score*10)/100 as "markup"
from student_scores;

# Q3. Calculate percentage of score
select (score*100)/100 as "percentage"
from student_scores;

# Q4. Students with scores between 40 and 60
select student_id, score
from student_scores
where score between 40 and 60;

# Q5. Show number of tests per test type
select test_type, count(test_type)
from student_scores
group by test_type;

# Q13. DENSE_RANK by student performance in Math
select subject_name,
dense_rank() over (order by subject_id) as "dense_rank"
from subjects
where subject_name="Math";

# Q14. UPDATE student_scores to scale up all scores by 5%
update student_scores
set score=(score*5)/100
where score<50;

# Q15. DELETE scores with 0 value
delete from student_scores
where score=0;

# Q16. ALTER TABLE examples
alter table student_scores
drop column extra_credit; 

alter table student_scores
modify column score float not null;

# Q. Subtract 2 marks for late submission
select (score-2) as "late submission"
from student_scores
where test_date <"2024-01-01";

# Q. Excellent, Good, Needs Improvement
select (score*1000) 
from student_scores;

update student_scores
set score = score*1000;

select student_id, score,
case 
   when score >=75 then "Excellent"
   when score between 50 and 75 then "Good"
   else "Needs Improvement"
   end as "performance"
   from student_scores;

# Q8. Day difference between test and signup

select student_id, test_date,
datediff (curdate(), test_date) as "days"
from student_scores;

# Q. Find subject-wise average scores using JOIN
select ss.subject_id, ss.subject_name, t.avg
from subjects as ss
join (select subject_id, avg(score) as "avg"
                     from student_scores 
                     group by subject_id)
t on ss.subject_id=t.subject_id;

# Q. Use LAG to compare current and previous score
select score,student_id,
lag(score) over (order by student_id) as "LAG",
lead(score) over (order by student_id) as "Lead"
from student_scores;

# Q. Get students who scored above the average score for their respective subject
select name
from students
where student_id in (select student_id
                    from student_scores
                    where score > (select avg(score)
					from student_scores));

# Q. Get list of teachers and class teachers
select name, teacher_id from teachers
union 
select class_name, class_teacher_id from classes;

# Q. Top-scoring subject per student (ROW_NUMBER + CTE)#

select s.subject_name, t.max
from subjects as s
join (select subject_id, max(score) as "max"
						 from student_scores
						 group by subject_id)
t on s.subject_id=t.subject_id;

with my_cte as(
select score, student_id, subject_id,
row_number() over (partition by student_id order by student_id) as "row"
from student_scores)

select score
from my_cte;

# Q. PERCENT_RANK by score in final exams
select score, 
PERCENT_RANK() over (order by score) as "PERCENT_RANK"
from student_scores;

select * from student_scores;
select * from students;
select * from subjects;
select * from classes;
select * from teachers;

alter table classes
rename column class_teacher_id to teacher_id;

# Q1. Show each class and its assigned class teacher's name

select c.class_name, t.name
from classes as c
left join teachers as t
on c.teacher_id=t.teacher_id;

# Q3. Total number of classes each teacher is managing

select * from classes;
select * from teachers;

select tea.name, t.total_class
from teachers as tea
join (select teacher_id, count(class_id) as "total_class"
					from classes as t
				    group by teacher_id)
as t on tea.teacher_id=t.teacher_id;

# Q9. Using RANK() to rank teachers by experience
select name, experience_years,
rank() over (order by experience_years desc) as "rank"
from teachers;


# Q. Find teachers with more than 2 classes assigned

select name
from teachers
where teacher_id in (select teacher_id
                     from classes
                     group by teacher_id
                     having count(class_id)>2);

# Q. Average experience of teachers by subject specialty

select * from subjects;
select * from classes;
select * from teachers;

select subject_specialty, avg(experience_years) as "Avg_Exp"
from teachers
group by subject_specialty;



