USE INDIAN_CENCUS;
SELECT * FROM dataset1 ;
select * from dataset2_population;
-- number of rows into our dataset

select count(*) from indian_cencus.dataset1;
select count(*) from indian_cencus.dataset2_population;

# dataset for Madhya Pradesh and Kerala

select * from dataset1 where state in ('Madhya Pradesh' ,'Kerala');

# population OF Inida

SELECT sum(Population) as Population FROM  dataset2_population ;

-- avg growth 

select state,avg(growth)*100 avg_growth from dataset1 group by state;

-- avg sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from dataset1 group by state order by avg_sex_ratio desc;

-- avg literacy rate greater than 75
 
select state,round(avg(literacy),0) avg_literacy_ratio from dataset1 
group by state having round(avg(literacy),0)>75 order by avg_literacy_ratio desc ;

-- top 5 state showing highest growth ratio


select  state,avg(growth)*100 avg_growth from dataset1 group by state order by avg_growth desc limit 5 ;


-- bottom 5 state showing lowest sex ratio

select state,round(avg(sex_ratio),0) avg_sex_ratio from dataset1 group by state order by avg_sex_ratio asc limit 5;


-- top and bottom 5 states in literacy state

drop table if exists Topstates;
create table Topstates
( state varchar(255),
  topstate float

  );

insert into Topstates
select state,round(avg(literacy),0) avg_literacy_ratio from dataset1 
group by state order by avg_literacy_ratio desc;

select * from Topstates 
 order by topstate desc;

drop table if exists bottomstates;
create table bottomstates
( state varchar(255),
  bottomstate float

  );

insert into bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from dataset1 
group by state order by avg_literacy_ratio ASC;

select  * from bottomstates order by bottomstates.bottomstate asc LIMIT  5;

-- union opertor

select * from (
select  * from Topstates order by topstates.topstate desc LIMIT 5 ) a

union

select * from (
select * from bottomstates order by bottomstates.bottomstate asc LIMIT 5) b;


-- states starting with letter a or b

SELECT DISTINCT
    state
FROM
    dataset1
WHERE
    state LIKE 'a%' OR state LIKE 'b%';
    
--  states  srarting with letter a ending with letter h
select distinct state from dataset1 where state like 'a%' and state like '%h';


-- joining both table

-- total males and females

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from dataset1 a inner join dataset2_population b on a.district=b.district ) c) d
group by d.state;

-- total literacy rate


select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.state,a.literacy/100 literacy_ratio,b.population from dataset1 a 
inner join dataset2_population b on a.district=b.district) d) c
group by c.state;

-- population in previous census


select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth  ,b.population from dataset1 a inner join dataset2_population b on a.district=b.district) d) e
group by e.state)m;




-- window function

-- output  districts from each state with highest literacy rate limit 5;


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from dataset1) a

where a.rnk in (1,2,3,4,5) order by state ;
