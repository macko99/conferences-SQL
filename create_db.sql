DROP TABLE IF EXISTS conferences.conference_day_price
DROP TABLE IF EXISTS conferences.student_attendee
DROP TABLE IF EXISTS conferences.workshop_attendee
DROP TABLE IF EXISTS conferences.conference_day_attendee
DROP TABLE IF EXISTS conferences.attendee
DROP TABLE IF EXISTS conferences.workshop_order_item
DROP TABLE IF EXISTS conferences.conference_day_order_item
DROP TABLE IF EXISTS conferences.orders
DROP TABLE IF EXISTS conferences.buyer
DROP TABLE IF EXISTS conferences.company
DROP TABLE IF EXISTS conferences.workshop
DROP TABLE IF EXISTS conferences.conference_day
DROP TABLE IF EXISTS conferences.conference

DROP VIEW IF EXISTS conferences.attendees_badges
DROP VIEW IF EXISTS conferences.buyer_statistics
DROP VIEW IF EXISTS conferences.cancelled_orders
DROP VIEW IF EXISTS conferences.client_statistics
DROP VIEW IF EXISTS conferences.income_statistics
DROP VIEW IF EXISTS conferences.missing_attendees_data
DROP VIEW IF EXISTS conferences.order_summary
DROP VIEW IF EXISTS conferences.unpaid_orders
DROP VIEW IF EXISTS conferences.upcoming_conferences
DROP VIEW IF EXISTS conferences.workshop_available_attendees

DROP PROCEDURE IF EXISTS conferences.add_buyer
DROP PROCEDURE IF EXISTS conferences.add_conference
DROP PROCEDURE IF EXISTS conferences.add_conference_day_attendee_to_order
DROP PROCEDURE IF EXISTS conferences.add_day_price
DROP PROCEDURE IF EXISTS conferences.add_day_to_conference
DROP PROCEDURE IF EXISTS conferences.add_day_to_order
DROP PROCEDURE IF EXISTS conferences.add_order_payment
DROP PROCEDURE IF EXISTS conferences.add_workshop
DROP PROCEDURE IF EXISTS conferences.add_workshop_attendee_to_order
DROP PROCEDURE IF EXISTS conferences.add_workshop_to_order
DROP PROCEDURE IF EXISTS conferences.cancel_order
DROP PROCEDURE IF EXISTS conferences.cancel_unpaid_orders

DROP FUNCTION IF EXISTS conferences.conference_attendees
DROP FUNCTION IF EXISTS conferences.conference_day_attendees
DROP FUNCTION IF EXISTS conferences.conference_day_price_by_date
DROP FUNCTION IF EXISTS conferences.conference_days
DROP FUNCTION IF EXISTS conferences.conference_workshops

DROP PROCEDURE IF EXISTS conferences.delete_conference_day_attendee_from_order
DROP PROCEDURE IF EXISTS conferences.delete_conference_day_from_order
DROP PROCEDURE IF EXISTS conferences.delete_workshop_attendee_from_order
DROP PROCEDURE IF EXISTS conferences.delete_workshop_from_order
DROP PROCEDURE IF EXISTS conferences.get_conference_day_attendees_count
DROP PROCEDURE IF EXISTS conferences.get_workshops_in_a_day
DROP PROCEDURE IF EXISTS conferences.modify_workshop_attendee_limit
DROP PROCEDURE IF EXISTS conferences.modify_workshop_price

DROP FUNCTION IF EXISTS conferences.registered_conference_attendees_in_order
DROP FUNCTION IF EXISTS conferences.registered_workshop_attendees_in_order
DROP FUNCTION IF EXISTS conferences.workshop_attendees
DROP FUNCTION IF EXISTS conferences.workshop_available_places


DROP TRIGGER IF EXISTS conferences.conference_day_attendee_greater_than_workshop_attendee
DROP TRIGGER IF EXISTS conferences.payment_deadline
DROP TRIGGER IF EXISTS conferences.price_expire_not_after_conference_date
DROP TRIGGER IF EXISTS conferences.exists_price_till_conference
DROP TRIGGER IF EXISTS conferences.one_attendee_per_private_buyer
DROP TRIGGER IF EXISTS conferences.order_before_conference_day
DROP TRIGGER IF EXISTS conferences.too_many_attendees_after_limiting_places
DROP TRIGGER IF EXISTS conferences.cancel_order_trigger
DROP TRIGGER IF EXISTS conferences.same_conference_day_exists_in_order
DROP TRIGGER IF EXISTS conferences.remove_attendee_if_neccessary
DROP TRIGGER IF EXISTS conferences.remove_conference_day_attendee_after_remove_conference_day_order_item
DROP TRIGGER IF EXISTS conferences.remove_workshop_attendee_after_remove_workshop_order_item
DROP TRIGGER IF EXISTS conferences.remove_workshop_attendee_after_remove_conference_day_attendee
DROP TRIGGER IF EXISTS conferences.remove_workshop_order_item_after_last_workshop_attendee_removed
DROP TRIGGER IF EXISTS conferences.order_workshop_only_if_ordered_proper_conference_day
DROP TRIGGER IF EXISTS conferences.workshop_overlapping
DROP TRIGGER IF EXISTS conferences.not_enough_workshop_places

CREATE TABLE conferences.company
(
    company_id INT PRIMARY KEY IDENTITY (1, 1),
    name       VARCHAR(32)  NOT NULL UNIQUE,
    address    VARCHAR(128) NOT NULL,
    phone      VARCHAR(12)  NOT NULL
);

CREATE TABLE conferences.conference
(
    conference_id    INT PRIMARY KEY IDENTITY (1, 1),
    name             VARCHAR(32),
    description      VARCHAR(256),
    student_discount INT NOT NULL CHECK (student_discount BETWEEN 0 and 100) DEFAULT 0
);

CREATE TABLE conferences.attendee
(
    attendee_id INT PRIMARY KEY IDENTITY (1, 1),
    first_name  VARCHAR(32),
    last_name   VARCHAR(32),
    email       VARCHAR(64) UNIQUE CHECK (email IS NULL OR email LIKE '%@%'),
    company_id  INT,
    FOREIGN KEY (company_id) REFERENCES conferences.company (company_id)
);

CREATE TABLE conferences.conference_day
(
    conference_day_id INT PRIMARY KEY IDENTITY (1, 1),
    conference_id     INT      NOT NULL,
    date              DATETIME NOT NULL,
    FOREIGN KEY (conference_id) REFERENCES conferences.conference (conference_id)
);

CREATE TABLE conferences.buyer
(
    buyer_id   INT PRIMARY KEY IDENTITY (1, 1),
    company_id INT,
    first_name VARCHAR(32)  NOT NULL,
    last_name  VARCHAR(32)  NOT NULL,
    address    VARCHAR(128) NOT NULL,
    FOREIGN KEY (company_id) REFERENCES conferences.company (company_id)
);

CREATE TABLE conferences.student_attendee
(
    attendee_id     INT PRIMARY KEY,
    student_card_id INT NOT NULL,
    FOREIGN KEY (attendee_id) REFERENCES conferences.attendee (attendee_id)
);

CREATE TABLE conferences.orders
(
    order_id     INT PRIMARY KEY IDENTITY (1, 1),
    buyer_id     INT NOT NULL,
    cancelled    TINYINT CHECK (cancelled = 1 OR cancelled = 0) DEFAULT 0,
    payment_type VARCHAR(16) CHECK (payment_type in ('cash', 'card', 'transfer', 'cheque')),
    value        INT CHECK (value >= 0),
    date         DATETIME,
    FOREIGN KEY (buyer_id) REFERENCES conferences.buyer (buyer_id)
);

CREATE TABLE conferences.workshop
(
    workshop_id       INT PRIMARY KEY IDENTITY (1, 1),
    conference_day_id INT          NOT NULL,
    name              VARCHAR(64)  NOT NULL,
    description       VARCHAR(256) NOT NULL,
    price             INT          NOT NULL CHECK (price >= 0),
    date_start        DATETIME     NOT NULL,
    date_end          DATETIME     NOT NULL,
    attendees_limit   INT          NOT NULL CHECK (attendees_limit > 0),
    FOREIGN KEY (conference_day_id) REFERENCES conferences.conference_day (conference_day_id),
    CONSTRAINT end_date_after_start_date CHECK (date_start < date_end)
);

CREATE TABLE conferences.conference_day_order_item
(
    conference_day_order_item_id INT PRIMARY KEY IDENTITY (1, 1),
    order_id                     INT NOT NULL,
    conference_day_id            INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES conferences.orders (order_id),
    FOREIGN KEY (conference_day_id) REFERENCES conferences.conference_day (conference_day_id)
);

CREATE TABLE conferences.conference_day_attendee
(
    conference_day_attendee_id   INT PRIMARY KEY IDENTITY (1, 1),
    attendee_id                  INT,
    conference_day_order_item_id INT NOT NULL,
    FOREIGN KEY (attendee_id) REFERENCES conferences.attendee (attendee_id),
    FOREIGN KEY (conference_day_order_item_id) REFERENCES conferences.conference_day_order_item (conference_day_order_item_id)
);

CREATE TABLE conferences.conference_day_price
(
    price_id          INT PRIMARY KEY IDENTITY (1, 1),
    conference_day_id INT          NOT NULL,
    value             INT          NOT NULL CHECK (value >= 0),
    description       VARCHAR(256) NOT NULL,
    expiration_date   DATETIME     NOT NULL,
    FOREIGN KEY (conference_day_id) REFERENCES conferences.conference_day (conference_day_id)
);

CREATE TABLE conferences.workshop_order_item
(
    workshop_order_item_id       INT PRIMARY KEY IDENTITY (1, 1),
    conference_day_order_item_id INT NOT NULL,
    workshop_id                  INT NOT NULL,
    FOREIGN KEY (conference_day_order_item_id) REFERENCES conferences.conference_day_order_item (conference_day_order_item_id),
    FOREIGN KEY (workshop_id) REFERENCES conferences.workshop (workshop_id)
);

CREATE TABLE conferences.workshop_attendee
(
    workshop_attendee_id       INT PRIMARY KEY IDENTITY (1, 1),
    conference_day_attendee_id INT NOT NULL,
    workshop_order_item_id     INT NOT NULL,
    FOREIGN KEY (conference_day_attendee_id) REFERENCES conferences.conference_day_attendee (conference_day_attendee_id),
    FOREIGN KEY (workshop_order_item_id) REFERENCES conferences.workshop_order_item (workshop_order_item_id)
);


CREATE VIEW conferences.attendees_badges AS
SELECT a.first_name, a.last_name, a.email, ISNULL(c.name, '') as company_name
FROM conferences.attendee a
         JOIN conferences.company c ON a.company_id = c.company_id
go


CREATE VIEW conferences.buyer_statistics AS
SELECT b.first_name, b.last_name, ISNULL(c.name, '') AS company_name, SUM(o.value) AS total
FROM conferences.buyer b
         LEFT JOIN conferences.orders o ON b.buyer_id = o.buyer_id
         LEFT JOIN conferences.company c ON b.company_id = c.company_id
GROUP BY b.first_name, b.last_name, ISNULL(c.name, '')
go


CREATE VIEW conferences.cancelled_orders AS
SELECT o.order_id, b.first_name AS buyer_first_name, b.last_name AS buyer_last_name, ISNULL(c.name, '') AS company
FROM conferences.orders o
         JOIN conferences.buyer b ON o.buyer_id = b.buyer_id
         LEFT JOIN conferences.company c ON b.company_id = c.company_id
WHERE o.cancelled = 1
go


CREATE VIEW conferences.client_statistics AS
SELECT a.first_name, a.last_name, a.email, c.name AS conference_name, COUNT(*) AS attended
FROM conferences.attendee a
         JOIN conferences.conference_day_attendee cda ON a.attendee_id = cda.attendee_id
         JOIN conferences.conference_day_order_item cdoi
              ON cdoi.conference_day_order_item_id = cda.conference_day_order_item_id
         JOIN conferences.conference_day cd ON cd.conference_day_id = cdoi.conference_day_id
         JOIN conferences.conference c ON c.conference_id = cd.conference_day_id
GROUP BY a.first_name, a.last_name, a.email, c.name
WITH ROLLUP
go


CREATE VIEW conferences.income_statistics AS
SELECT YEAR(o.date)  AS year,
       MONTH(o.date) AS month,
       (
           SELECT SUM(o2.value)
           FROM conferences.orders o2
           WHERE YEAR(o2.date) = YEAR(o.date)
             AND MONTH(o2.date) = MONTH(o.date)
       )             AS income
FROM conferences.orders o
go


CREATE VIEW conferences.missing_attendees_data AS
SELECT cdoi.order_id AS order_id,
       c.name        AS conference_name,
       cd.date       AS conference_date,
       (
           SELECT COUNT(*)
           FROM conferences.conference_day_attendee cda
           WHERE cda.conference_day_order_item_id = cdoi.conference_day_order_item_id
             AND cda.attendee_id IS NOT NULL
       )             AS registered_attendees_data,
       (
           SELECT COUNT(*)
           FROM conferences.conference_day_attendee cda
           WHERE cda.conference_day_order_item_id = cdoi.conference_day_order_item_id
             AND cda.attendee_id IS NULL
       )             AS missing_attendees_data
FROM conferences.conference_day_order_item cdoi
         JOIN conferences.conference_day_attendee cda
              ON cdoi.conference_day_order_item_id = cda.conference_day_order_item_id
         JOIN conferences.conference_day cd ON cd.conference_day_id = cdoi.conference_day_id
         JOIN conferences.conference c ON c.conference_id = cd.conference_id
go


CREATE VIEW conferences.order_summary AS
SELECT o.order_id AS order_id,
       (
           SELECT COUNT(DISTINCT c.conference_id)
           FROM conferences.conference c
                    JOIN conferences.conference_day cd ON c.conference_id = cd.conference_id
                    JOIN conferences.conference_day_order_item cdoi ON cd.conference_day_id = cdoi.conference_day_id
                    JOIN conferences.orders o2 ON cdoi.order_id = o2.order_id
           WHERE o2.order_id = o.order_id
       )          AS total_conferences,
       (
           SELECT COUNT(DISTINCT cd.conference_day_id)
           FROM conferences.conference_day cd
                    JOIN conferences.conference_day_order_item cdoi ON cd.conference_day_id = cdoi.conference_day_id
                    JOIN conferences.orders o2 ON cdoi.order_id = o2.order_id
           WHERE o2.order_id = o.order_id
       )          AS total_conference_days,
       (
           SELECT COUNT(DISTINCT w.workshop_id)
           FROM conferences.workshop w
                    JOIN conferences.workshop_order_item woi ON w.workshop_id = woi.workshop_id
                    JOIN conferences.conference_day_order_item cdoi
                         ON woi.conference_day_order_item_id = cdoi.conference_day_order_item_id
                    JOIN conferences.orders o2 ON cdoi.order_id = o2.order_id
           WHERE o2.order_id = o.order_id
       )          AS total_workshops,
       (
           SELECT COUNT(DISTINCT cda.conference_day_attendee_id)
           FROM conferences.conference_day_attendee cda
                    JOIN conferences.conference_day_order_item cdoi
                         ON cda.conference_day_order_item_id = cdoi.conference_day_order_item_id
                    JOIN conferences.orders o2 ON cdoi.order_id = o2.order_id
           WHERE o2.order_id = o.order_id
       )          AS total_conference_attendees,
       (
           SELECT COUNT(DISTINCT wa.workshop_attendee_id)
           FROM conferences.workshop_attendee wa
                    JOIN conferences.conference_day_attendee cda
                         ON wa.conference_day_attendee_id = cda.conference_day_attendee_id
                    JOIN conferences.conference_day_order_item cdoi
                         ON cda.conference_day_order_item_id = cdoi.conference_day_order_item_id
                    JOIN conferences.orders o2 ON cdoi.order_id = o2.order_id
           WHERE o2.order_id = o.order_id
       )          AS total_workshop_attendees
FROM conferences.orders o
go


CREATE VIEW conferences.unpaid_orders AS
SELECT o.order_id, b.first_name AS buyer_first_name, b.last_name AS buyer_last_name, ISNULL(c.name, '') AS company
FROM conferences.orders o
         JOIN conferences.buyer b ON o.buyer_id = b.buyer_id
         LEFT JOIN conferences.company c ON b.company_id = c.company_id
WHERE o.cancelled = 0
  AND o.value IS NULL
go


CREATE VIEW conferences.upcoming_conferences AS
SELECT name, date_start, date_end
FROM (
         SELECT c.conference_id, c.name AS name, MIN(cd.date) as date_start, MAX(cd.date) as date_end
         FROM conferences.conference c
                  JOIN conferences.conference_day cd ON c.conference_id = cd.conference_id
         GROUP BY c.conference_id, c.name
         HAVING MIN(cd.date) > GETDATE()
     ) as cc
go

CREATE VIEW conferences.workshop_available_attendees AS
SELECT c.name AS conference_name,
       w.name AS workshop_name,
       (w.attendees_limit - (
           SELECT COUNT(*)
           FROM conferences.workshop_attendee wa
                    JOIN conferences.workshop_order_item woi ON wa.workshop_order_item_id = woi.workshop_order_item_id
                    JOIN conferences.workshop w2 ON w2.workshop_id = woi.workshop_id
           WHERE w2.workshop_id = w.workshop_id
       ))     AS available_attendees
FROM conferences.workshop w
         JOIN conferences.conference_day cd ON w.conference_day_id = cd.conference_day_id
         JOIN conferences.conference c ON cd.conference_id = c.conference_id
go

CREATE FUNCTION conferences.conference_days(
    @conference_id INT
)
    RETURNS @days TABLE
                  (
                      conference_day_id INT,
                      date              DATETIME
                  )
AS
BEGIN
    INSERT INTO @days
    SELECT cd.conference_day_id, cd.date
    FROM conferences.conference_day cd
    WHERE cd.conference_id = @conference_id
    RETURN;
END

CREATE FUNCTION conferences.conference_day_price_by_date(@conference_day_id INT,
                                                         @date DATETIME)
    RETURNS INT
AS
BEGIN
    SELECT
    TOP 1
    cdp.value
    FROM conferences.conference_day_price cdp
    WHERE cdp.conference_day_id = @conference_day_id
      AND cdp.expiration_date >= @date
    ORDER BY cdp.expiration_date ASC
END

CREATE FUNCTION conferences.conference_workshops(
    @conference_id INT
)
    RETURNS @workshops TABLE
                       (
                           workshop_id       INT,
                           conference_day_id INT,
                           name              VARCHAR,
                           description       VARCHAR
                       )
AS
BEGIN
    INSERT INTO @workshops
    SELECT w.workshop_id, w.conference_day_id, w.name, w.description
    FROM conferences.workshop w
             JOIN conference_day cd on w.conference_day_id = cd.conference_day_id
             JOIN conference c on cd.conference_id = c.conference_id
    WHERE C.conference_id = @conference_id
    RETURN
END

CREATE FUNCTION conferences.conference_attendees(
    @conference_id INT
)
    RETURNS @attendees TABLE
                       (
                           attendee_id INT,
                           first_name  VARCHAR,
                           last_name   VARCHAR,
                           email       VARCHAR
                       )
AS
BEGIN
    INSERT INTO @attendees
    SELECT a.attendee_id, a.first_name, a.last_name, a.email
    FROM conference_day_attendee cda
             JOIN conference_day_order_item cdoi on cda.conference_day_order_item_id = cdoi.conference_day_order_item_id
             JOIN conference_day cd on cdoi.conference_day_id = cd.conference_day_id
             JOIN attendee a on cda.attendee_id = a.attendee_id
    WHERE cd.conference_id = @conference_id
    RETURN
END

CREATE FUNCTION conferences.conference_day_attendees(
    @conference_day_id INT
)
    RETURNS @attendees TABLE
                       (
                           attendee_id INT,
                           first_name  VARCHAR,
                           last_name   VARCHAR,
                           email       VARCHAR
                       )
AS
BEGIN
    INSERT INTO @attendees
    SELECT a.attendee_id, a.first_name, a.last_name, a.email
    FROM conference_day_attendee cda
             JOIN conference_day_order_item cdoi on cda.conference_day_order_item_id = cdoi.conference_day_order_item_id
             JOIN attendee a on cda.attendee_id = a.attendee_id
    WHERE cdoi.conference_day_id = @conference_day_id
    RETURN
END

CREATE FUNCTION conferences.workshop_available_places(
    @workshop_id INT
)
    RETURNS INT
AS
BEGIN
    SELECT w.attendees_limit - (
        SELECT COUNT(*)
        FROM conferences.workshop_attendee wa
                 JOIN conferences.workshop_order_item woi ON wa.workshop_order_item_id = woi.workshop_order_item_id
                 JOIN conferences.workshop w2 ON woi.workshop_id = w2.workshop_id
        WHERE w2.workshop_id = @workshop_id
    )
    FROM conferences.workshop w
    WHERE w.workshop_id = @workshop_id
END

CREATE FUNCTION conferences.workshop_attendees(
    @workshop_id INT
)
    RETURNS INT
AS
BEGIN
    SELECT COUNT(*)
    FROM conferences.workshop_attendee wa
             JOIN conferences.workshop_order_item woi ON wa.workshop_order_item_id = woi.workshop_order_item_id
             JOIN conferences.workshop w ON woi.workshop_id = w.workshop_id
    WHERE w.workshop_id = @workshop_id
END

CREATE FUNCTION conference.registered_conference_attendees_in_order(
    @order_id INT
)
    RETURNS @attendees TABLE
                       (
                           conference_id        INT,
                           conference_day_id    INT,
                           registered_attendees INT
                       )
AS
BEGIN
    INSERT INTO @attendees
    SELECT cd.conference_id, cd.conference_day_id, COUNT(*) AS registered_attendees
    FROM conferences.conference_day_attendee cda
             JOIN conferences.conference_day_order_item
                  ON cda.conference_day_order_item_id = conference_day_order_item.conference_day_order_item_id
             JOIN conferences.conference_day cd ON conference_day_order_item.conference_day_id = cd.conference_day_id
             JOIN conferences.orders o ON conference_day_order_item.order_id = o.order_id
    WHERE o.order_id = @order_id
    GROUP BY cd.conference_id, cd.conference_day_id
    RETURN;
END


CREATE FUNCTION conferences.registered_workshop_attendees_in_order(
    @order_id INT
)
    RETURNS @attendees TABLE
                       (
                           conference_id        INT,
                           conference_day_id    INT,
                           workshop_id          INT,
                           registered_attendees INT
                       )
AS
BEGIN
    INSERT INTO @attendees
    SELECT cd.conference_id, cd.conference_day_id, w.workshop_id, COUNT(*) AS registered_attendees
    FROM conferences.workshop_attendee wa
             JOIN conferences.workshop_order_item woi on wa.workshop_order_item_id = woi.workshop_order_item_id
             JOIN conferences.workshop w on woi.workshop_id = w.workshop_id
             JOIN conferences.conference_day cd on w.conference_day_id = cd.conference_day_id
             JOIN conferences.conference_day_order_item cdoi
                  ON woi.conference_day_order_item_id = cdoi.conference_day_order_item_id
    WHERE cdoi.order_id = @order_id
    GROUP BY cd.conference_id, cd.conference_day_id, w.workshop_id
END

CREATE PROCEDURE conferences.get_conference_day_attendees_count @conference_id INT
AS
BEGIN
    select count(*)
    from conferences.conference_day_attendee ca
             join conferences.conference_day_order_item co
                  on ca.conference_day_order_item_id = co.conference_day_order_item_id
             join conferences.conference_day cd
                  on cd.conference_day_id = co.conference_day_id
    where cd.conference_id = @conference_id
    group by cd.conference_day_id
end
go

create procedure conferences.get_workshops_in_a_day @conference_day_id INT
as
begin
    select name, description, price, attendees_limit
    from conferences.workshop
    where conference_day_id = @conference_day_id
end
go


create procedure conferences.add_conference @name varchar(32),
                                @date datetime,
                                @description varchar(256)
as
begin
    if not exists(select *
                  from conferences.conference_day
                  where year(date) = year(@date)
                    and month(date) = month(@date)
                    and day(date) = day(@date))
        begin try
            insert into conferences.conference (name, description)
            VALUES (@name, @description)
            insert into conferences.conference_day (conference_id, date)
            VALUES ((select top 1 conference_id from conferences.conference Order By conference_id desc), @date)
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error when adding conference: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        THROW 52000, 'conference in this day already exists!', 1;
end
go

create procedure conferences.add_workshop @name varchar(32),
                              @description varchar(256),
                              @price INT,
                              @date_start datetime,
                              @date_end datetime,
                              @attendees_limit int
as
begin
    if exists(select *
              from conferences.conference_day
              where year(date) = year(@date_start)
                and month(date) = month(@date_start)
                and day(date) = day(@date_start))
        begin try
            insert into conferences.workshop(conference_day_id, name, description, price, date_start, date_end,
                                             attendees_limit)
            values ((select conference_day_id from conferences.conference_day where date = @date_start), @name,
                    @description, @price, @date_start, @date_end, @attendees_limit);
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error when adding workshop: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        THROW 52000, 'conference day does not exist!', 1;
end
go

create procedure conferences.add_day_price @conference_day_id int,
                               @value int,
                               @description varchar(256),
                               @expiration_date datetime
as
begin
    if not exists(select * from conferences.conference_day_price where expiration_date = @expiration_date)
        begin try
            insert into conferences.conference_day_price
            values (@conference_day_id, @value, @description, @expiration_date);
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error when adding day price: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        throw 52000, 'Such day price already exists!', 1;
end
go

create procedure conferences.add_day_to_conference @conference_id int,
                                       @date datetime
as
begin
    if not exists(select *
                  from conferences.conference_day
                  where year(date) = year(@date)
                    and month(date) = month(@date)
                    and day(date) = day(@date))
        begin try
            insert into conferences.conference_day values (@conference_id, @date);
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error when adding day to conference: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        throw 52000, 'Such day already exists!', 1;
end
go

create procedure conferences.add_day_to_order @order_id int,
                                  @conference_day_id int
as
begin
    if exists(select * from conferences.conference_day where conference_day_id = @conference_day_id)
        and
       exists(select * from conferences.orders where order_id = @order_id)
        begin try
            insert into conferences.conference_day_order_item values (@order_id, @conference_day_id)
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error when adding day to order: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        THROW 52000, 'no such order or conference day!', 1;
end
go

create procedure conferences.add_workshop_to_order @order_id int,
                                       @workshop_id int
as
begin
    declare @date int;
    set @date = (select conference_day_id from conferences.workshop where workshop_id = @workshop_id)
    if exists(select *
              from conferences.conference_day_order_item
              where order_id = @order_id
                and conference_day_id = @date)
        begin try
            declare @conference_day_order_item_id int;
            set @conference_day_order_item_id = (select conference_day_order_item_id
                                                 from conferences.conference_day_order_item
                                                 where order_id = @order_id
                                                   and conference_day_id = @date)
            insert into conferences.workshop_order_item values (@conference_day_order_item_id, @workshop_id)
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error when adding workshop to order: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        THROW 52000, 'order does not contain conference day in day of this workshop', 1;
end
go

create procedure conferences.delete_workshop_from_order @order_id int,
                                            @workshop_id int
as
begin
    declare @date int;
    set @date = (select conference_day_id from conferences.workshop where workshop_id = @workshop_id)
    declare @conference_day_order_item_id int;
    set @conference_day_order_item_id = (select conference_day_order_item_id
                                         from conferences.conference_day_order_item
                                         where order_id = @order_id
                                           and conference_day_id = @date)
    if exists(select *
              from conferences.workshop_order_item
              where workshop_id = @workshop_id
                and conference_day_order_item_id = @conference_day_order_item_id)
        begin try
            declare @workshop_order_item_id int;
            set @workshop_order_item_id = (select workshop_order_item_id
                                           from conferences.workshop_order_item
                                           where workshop_id = @workshop_order_item_id
                                             and conference_day_order_item_id = @conference_day_order_item_id)

            delete
            from conferences.workshop_order_item
            where workshop_id = @workshop_id
              and conference_day_order_item_id = @conference_day_order_item_id
            delete from conferences.workshop_attendee where workshop_attendee_id = @workshop_order_item_id
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error removing workshop from order: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        THROW 52000, 'no such workshop in order!', 1;
end
go

create procedure conferences.modify_workshop_price @price int,
                                       @workshop_id int
as
begin
    if exists(select * from conferences.workshop where workshop_id = @workshop_id)
        begin try
            update conferences.workshop set price = @price where workshop_id = @workshop_id
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error changing workshop price: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        THROW 52000, 'Workshop does not exists!', 1;
end
go

create procedure conferences.modify_workshop_attendee_limit @attendee_limit int,
                                                            @workshop_id int
as
begin
    if exists(select * from conferences.workshop where workshop_id = @workshop_id)
        begin try
            update conferences.workshop set attendees_limit = @attendee_limit where workshop_id = @workshop_id
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error changing workshop attendee limit: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    else
        THROW 52000, 'Workshop does not exists!', 1;
end
go

create procedure conferences.add_buyer @first_name varchar(32),
                           @last_name varchar(32),
                           @address varchar(128),
                           @name varchar(32),
                           @company_address varchar(128),
                           @company_phone varchar(12)
as
begin
    if exists(select *
              from conferences.buyer
              where first_name = @first_name
                and last_name = @last_name
                and address = @address)
        begin
            throw 52000, 'buyer exists!', 1
        end
    if @name is null
        begin try
            insert into conferences.buyer (first_name, last_name, address)
            values (@first_name, @last_name, @address)
        end try
        begin catch
            declare @errorMessage varchar(2048);
            set @errorMessage = 'error adding buyer: \n' + ERROR_MESSAGE();
            THROW 52000, @errorMessage, 1;
        end catch
    if @name is not NULL
        begin
            if not exists(select *
                          from conferences.company
                          where name = @name
                            and address = @company_address
                            and phone = @company_phone)
                begin try
                    insert into conferences.company values (@name, @company_address, @company_phone)
                    declare @company_id INT;
                    set @company_id = (select company_id
                                       from conferences.company
                                       where name = @name
                                         and address = @company_address
                                         and phone = @company_phone)
                    insert into conferences.buyer values (@company_id, @first_name, @last_name, @address);
                end try
                begin catch
                    declare @errorMessage2 varchar(2048);
                    set @errorMessage2 = 'error adding buyer or company: \n' + ERROR_MESSAGE();
                    THROW 52000, @errorMessage2, 1;
                end catch
            else
                begin try
                    declare @company_id2 INT;
                    set @company_id2 = (select company_id
                                       from conferences.company
                                       where name = @name
                                         and address = @company_address
                                         and phone = @company_phone)
                    insert into conferences.buyer values (@company_id2, @first_name, @last_name, @address);
                end try
                begin catch
                    declare @errorMessage3 varchar(2048);
                    set @errorMessage3 = 'error adding buyer or company: \n' + ERROR_MESSAGE();
                    THROW 52000, @errorMessage3, 1;
                end catch
        end
end


CREATE PROCEDURE conferences.add_order_payment @order_id INT,
                                   @payment_type VARCHAR,
                                   @value INT
AS
BEGIN TRY
    IF NOT EXISTS(SELECT * FROM conferences.orders o WHERE o.order_id = @order_id)
        BEGIN
            THROW 52000, 'Order with given ID not exist', 1;
        END
    UPDATE conferences.orders SET value = value + @value, payment_type = @payment_type WHERE order_id = @order_id;
END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while adding payment: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO

drop procedure conferences.add_order_payment


CREATE PROCEDURE conferences.cancel_order @order_id INT
AS
BEGIN TRY
    IF NOT EXISTS(SELECT * FROM conferences.orders o WHERE o.order_id = @order_id)
        BEGIN
            THROW 52000, 'Order with given ID not exist', 1;
        END
    UPDATE conferences.orders SET cancelled = 1 WHERE order_id = @order_id;

    DELETE wa
    FROM conferences.workshop_attendee wa
             JOIN conferences.workshop_order_item woi ON wa.workshop_order_item_id = woi.workshop_order_item_id
             JOIN conferences.conference_day_order_item cdoi
                  ON woi.conference_day_order_item_id = cdoi.conference_day_order_item_id
    WHERE cdoi.order_id = @order_id;

    DELETE cda
    FROM conferences.conference_day_attendee cda
             JOIN conferences.conference_day_order_item cdoi
                  ON cda.conference_day_order_item_id = cdoi.conference_day_order_item_id
    WHERE cdoi.order_id = @order_id;

    DELETE woi
    FROM conferences.workshop_order_item woi
             JOIN conferences.conference_day_order_item cdoi
                  ON woi.conference_day_order_item_id = cdoi.conference_day_order_item_id
    WHERE cdoi.order_id = @order_id;

    DELETE cdoi
    FROM conferences.conference_day_order_item cdoi
    WHERE cdoi.order_id = @order_id;
END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while cancelling order: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO

CREATE PROCEDURE conferences.cancel_unpaid_orders
AS
BEGIN TRY
    DECLARE query_cursor CURSOR FOR
        SELECT o.order_id FROM conferences.orders o WHERE DATEDIFF(day, o.date, GETDATE()) >= 7;

    DECLARE @order_id INT

    OPEN query_cursor
    FETCH NEXT FROM query_cursor INTO @order_id

    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC cancel_order @order_id;
        END
END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while cancelling unpaid orders: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO


CREATE PROCEDURE conferences.delete_conference_day_attendee_from_order @conference_day_attendee_id INT,
                                                           @order_id INT
AS
BEGIN TRY

    IF NOT EXISTS(SELECT * FROM conferences.orders o WHERE o.order_id = @order_id)
        BEGIN
            THROW 52000, 'Order with given ID not exist', 1;
        END

    IF NOT EXISTS(SELECT *
                  FROM conferences.conference_day_attendee cda
                  WHERE cda.conference_day_attendee_id = @conference_day_attendee_id)
        BEGIN
            THROW 52000, 'Conference attendee with given ID not exist', 1;
        END

    IF EXISTS(SELECT *
              FROM conferences.workshop_attendee wa
              WHERE wa.conference_day_attendee_id = @conference_day_attendee_id)
        BEGIN
            DELETE wa
            FROM conferences.workshop_attendee wa
            WHERE wa.conference_day_attendee_id = @conference_day_attendee_id;
        END

    DELETE cda
    FROM conferences.conference_day_attendee cda
    WHERE cda.conference_day_attendee_id = @conference_day_attendee_id;

END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while deleting conference day attendee from order: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO

CREATE PROCEDURE conferences.delete_workshop_attendee_from_order @workshop_attendee_id INT,
                                                     @order_id INT
AS
BEGIN TRY

    IF NOT EXISTS(SELECT * FROM conferences.orders o WHERE o.order_id = @order_id)
        BEGIN
            THROW 52000, 'Order with given ID not exist', 1;
        END

    IF NOT EXISTS(SELECT *
                  FROM conferences.workshop_attendee wa
                  WHERE wa.conference_day_attendee_id = @workshop_attendee_id)
        BEGIN
            THROW 52000, 'Workshop attendee with given ID not exist', 1;
        END

    DELETE wa
    FROM conferences.workshop_attendee wa
    WHERE wa.workshop_attendee_id = @workshop_attendee_id;

END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while deleting workshop attendee from order: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO


CREATE PROCEDURE conferences.delete_conference_day_from_order @conference_day_id INT,
                                                  @order_id INT
AS
BEGIN TRY
    IF NOT EXISTS(SELECT * FROM conferences.orders o WHERE o.order_id = @order_id)
        BEGIN
            THROW 52000, 'Order with given ID not exist', 1;
        END

    IF NOT EXISTS(
            SELECT *
            FROM conferences.conference_day_order_item cdoi
            WHERE cdoi.order_id = @order_id
              AND cdoi.conference_day_id = @conference_day_id
        )
        BEGIN
            DECLARE @conference_day_order_item_id INT;
            SET @conference_day_order_item_id = (SELECT cdoi.conference_day_order_item_id
                                                 FROM conferences.conference_day_order_item cdoi
                                                 WHERE cdoi.order_id = @order_id
                                                   AND cdoi.conference_day_id = @conference_day_id);

            DELETE wa
            FROM conferences.workshop_attendee wa
                     JOIN conferences.workshop_order_item woi ON wa.workshop_order_item_id = woi.workshop_order_item_id
            WHERE woi.conference_day_order_item_id = @conference_day_order_item_id;

            DELETE cda
            FROM conferences.conference_day_attendee cda
            WHERE cda.conference_day_order_item_id = @conference_day_order_item_id;

            DELETE woi
            FROM conferences.workshop_order_item woi
            WHERE woi.conference_day_order_item_id = @conference_day_order_item_id;
        END
END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while deleting conference day from order: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO

CREATE PROCEDURE conferences.add_conference_day_attendee_to_order @order_id INT,
                                                      @conference_day_id INT,
                                                      @first_name VARCHAR,
                                                      @last_name VARCHAR,
                                                      @email VARCHAR,
                                                      @company_id INT,
                                                      @student_card_id VARCHAR
AS
BEGIN TRY
    IF NOT EXISTS(SELECT * FROM conferences.orders o WHERE o.order_id = @order_id)
        BEGIN
            THROW 52000, 'Order with given ID not exist', 1;
        END

    IF NOT EXISTS(SELECT * FROM conferences.conference_day cd WHERE cd.conference_day_id = @conference_day_id)
        BEGIN
            THROW 52000, 'Conference day with given ID not exist', 1;
        END

    IF NOT EXISTS(SELECT * FROM conferences.attendee a WHERE a.email = @email)
        BEGIN TRY
            IF (@company_id IS NOT NULL AND
                NOT EXISTS(SELECT * FROM conferences.company c WHERE c.company_id = @company_id))
                BEGIN
                    THROW 52000, 'Company with given ID not exist', 1;
                END

            INSERT INTO conferences.attendee (first_name, last_name, email, company_id)
            VALUES (@first_name, @last_name, @email, @company_id);

            DECLARE @attendee_id INT;
            SET @attendee_id = (SELECT a.attendee_id FROM conferences.attendee a WHERE a.email = @email);

            IF @student_card_id IS NOT NULL
                BEGIN TRY
                    IF EXISTS(SELECT * FROM conferences.student_attendee sa WHERE sa.student_card_id = @student_card_id)
                        BEGIN
                            THROW 52000, 'Student card with given CardID already exists', 1;
                        END

                    INSERT INTO conferences.student_attendee (attendee_id, student_card_id)
                    VALUES (@attendee_id, @student_card_id);
                END TRY
                BEGIN CATCH
                    THROW 52000, 'Error while adding student attendee', 1;
                END CATCH
        END TRY
        BEGIN CATCH
            THROW 52000, 'Error while adding attendee', 1;
        END CATCH

    DECLARE @attendee_id2 INT;
    SET @attendee_id2 = (SELECT a.attendee_id FROM conferences.attendee a WHERE a.email = @email);

    DECLARE @conference_order_item_id INT;
    SET @conference_order_item_id = (SELECT cdoi.conference_day_order_item_id
                                     FROM conferences.conference_day_order_item cdoi
                                     WHERE cdoi.order_id = @order_id
                                       AND cdoi.conference_day_id = @conference_day_id);

    INSERT INTO conferences.conference_day_attendee (attendee_id, conference_day_order_item_id)
    VALUES (@attendee_id2, @conference_order_item_id);
END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while adding conference attendee to order: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO

CREATE PROCEDURE conferences.add_workshop_attendee_to_order @order_id INT,
                                                @workshop_id INT,
                                                @first_name VARCHAR,
                                                @last_name VARCHAR,
                                                @email VARCHAR,
                                                @company_id INT,
                                                @student_card_id VARCHAR
AS
BEGIN TRY
    IF NOT EXISTS(SELECT * FROM conferences.orders o WHERE o.order_id = @order_id)
        BEGIN
            THROW 52000, 'Order with given ID not exist', 1;
        END

    IF NOT EXISTS(SELECT * FROM conferences.workshop w WHERE w.workshop_id = @workshop_id)
        BEGIN
            THROW 52000, 'Workshop with given ID not exist', 1;
        END

    IF NOT EXISTS(SELECT *
                  FROM conferences.conference_day_order_item cdoi
                           JOIN conferences.conference_day cd ON cdoi.conference_day_id = cd.conference_day_id
                           JOIN conferences.workshop w ON cd.conference_day_id = w.conference_day_id
                  WHERE w.workshop_id = @workshop_id
                    AND cdoi.order_id = @order_id)
        BEGIN
            THROW 52000, 'Cannot add attendee to workshop on not ordered conference day', 1;
        END

    DECLARE @attendees_limit INT;
    DECLARE @current_attendees INT;

    SET @attendees_limit = (SELECT w.attendees_limit FROM conferences.workshop w WHERE w.workshop_id = @workshop_id);

    SET @current_attendees = (SELECT COUNT(*)
                              FROM conferences.workshop_attendee wa
                                       JOIN conferences.workshop_order_item woi
                                            ON wa.workshop_order_item_id = woi.workshop_order_item_id
                              WHERE woi.workshop_id = @workshop_id);

    IF @current_attendees >= @attendees_limit
        BEGIN
            THROW 52000, 'Reached attendees limit to workshop with given ID', 1;
        END

    IF NOT EXISTS(SELECT * FROM conferences.attendee a WHERE a.email = @email)
        BEGIN
            THROW 52000, 'Attendee not registered to conference day when workshop take place', 1;
        END

    DECLARE @conference_day_order_item_id INT;
    SET @conference_day_order_item_id = (SELECT cdoi.conference_day_order_item_id
                                         FROM conferences.conference_day_order_item cdoi
                                                  JOIN conferences.conference_day cd
                                                       ON cdoi.conference_day_id = cd.conference_day_id
                                                  JOIN conferences.workshop w ON cd.conference_day_id = w.conference_day_id
                                         WHERE w.workshop_id = @workshop_id
                                           AND cdoi.order_id = @order_id);

    IF NOT EXISTS(SELECT *
                  FROM conferences.conference_day_attendee cda
                           JOIN conferences.attendee a ON cda.attendee_id = a.attendee_id
                  WHERE cda.conference_day_order_item_id = @conference_day_order_item_id
                    AND a.email = @email)
        BEGIN
            THROW 52000, 'Attendee not registered to conference day when workshop take place', 1;
        END

    IF NOT EXISTS(SELECT *
                  FROM conferences.workshop_order_item woi
                  WHERE woi.conference_day_order_item_id = @conference_day_order_item_id
                    AND woi.workshop_id = @workshop_id)
        BEGIN
            THROW 52000, 'Workshop not ordered yet', 1;
        END

    DECLARE @workshop_order_item_id INT;
    SET @workshop_order_item_id = (SELECT woi.workshop_order_item_id
                                   FROM conferences.workshop_order_item woi
                                   WHERE woi.workshop_id = @workshop_id
                                     AND woi.conference_day_order_item_id = @conference_day_order_item_id);

    DECLARE @attendee_id INT;
    SET @attendee_id = (SELECT a.attendee_id FROM conferences.attendee a WHERE a.email = @email);

    DECLARE @conference_day_attendee_id INT;
    SET @conference_day_attendee_id = (SELECT cda.conference_day_attendee_id
                                       FROM conferences.conference_day_attendee cda
                                       WHERE cda.attendee_id = @attendee_id
                                         AND cda.conference_day_order_item_id = @conference_day_order_item_id);


    INSERT INTO conferences.workshop_attendee (conference_day_attendee_id, workshop_order_item_id)
    VALUES (@conference_day_attendee_id, @workshop_order_item_id);
END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(2048);
    SET @errorMessage = 'Error while adding conference attendee to order: \n' + ERROR_MESSAGE();
    THROW 52000, @errorMessage, 1;
END CATCH
GO


CREATE TRIGGER conferences.not_enough_workshop_places
    ON conferences.workshop_order_item
    AFTER INSERT
    AS
BEGIN
    IF (conferences.workshop_available_places((select workshop_id from inserted)) < 0)
        BEGIN
            THROW 500001, 'Not enough places on selected workshop!', 1;
        END
END
go

create trigger conferences.conference_day_attendee_greater_than_workshop_attendee
    on conferences.conference_day_order_item
    after update
    as
begin
    if (select count(*)
        from conference_day_attendee
        where conference_day_order_item_id =
              (select conference_day_order_item_id from inserted))
        < (select count(*)
           from workshop_attendee wa
                    join conference_day_attendee cda on wa.conference_day_attendee_id = cda.conference_day_attendee_id
           where cda.conference_day_order_item_id =
                 (select conference_day_order_item_id from inserted))
        begin
            THROW 500001, 'Workshop attendees count must be lower than day attendees count!', 1;
        end
end
go

create trigger conferences.payment_deadline
    on conferences.orders
    after update
    as
begin
    if ((select value from inserted) is not null and datediff(day, (select date from inserted), getdate()) > 7)
        begin
            THROW 500001, 'Payment cannot be added later than 7 days after order!', 1;
        end
end
go

create trigger conferences.price_expire_not_after_conference_date
    ON conferences.conference_day_price
    after insert, update
    as
begin
    if ((select expiration_date from inserted) > (select date
                                                  from conference_day
                                                  where conference_day.conference_day_id =
                                                        (select conference_day_id from inserted)))
        begin
            THROW 500001, 'price expiration date must proceed conference date!', 1;
        end
end
go

create trigger conferences.exists_price_till_conference
    on conferences.conference_day_price
    after insert, update
    as
begin
    declare @conference_day_id int;
    set @conference_day_id = (select conference_day_id from inserted);
    if not (((select expiration_date from inserted) = (select date from conferences.conference_day where conference_day.conference_day_id
    = @conference_day_id)) or
       exists(select * from conference_day_price where conference_day_id = @conference_day_id and
            expiration_date = (select date from conference_day where conference_day.conference_day_id = @conference_day_id)))
    begin
        THROW 500001, 'there must be price ending on conference day!', 1;
    end
end
go

create trigger conferences.one_attendee_per_private_buyer
    on conferences.conference_day_order_item
    after insert, update
    as
begin
    if (select company_id
        from buyer
                 join orders on buyer.buyer_id = orders.buyer_id
        where orders.order_id = (select order_id from inserted)) is null
        begin
            if ((select count(*)
                 from conference_day_attendee
                 where conference_day_order_item_id = (select conference_day_order_item_id from inserted)) > 1)
                begin
                    THROW 500001, 'only one attendee allowed for private buyer!', 1;
                end
        end
end
go

create trigger conferences.order_before_conference_day
    on conferences.conference_day_order_item
    after insert, update
    as
begin
    if exists(select *
              from inserted i
                       join conferences.orders o
                            on i.order_id = o.order_id
                       join conferences.conference_day cd on cd.conference_day_id = i.conference_day_id
              where cd.date < o.date)
        begin
            THROW 500001, 'order must be placed before conference starts', 1;
        end
end
go

create trigger conferences.too_many_attendees_after_limiting_places
    on conferences.workshop
    after update
    as
begin
    if conferences.workshop_attendees((select workshop_id from inserted))
        > (select attendees_limit from inserted)
        begin
            THROW 500001, 'too many already booked places! cannot limit workshop!', 1;
        end
end
go


CREATE TRIGGER conferences.cancel_order_trigger
    ON conferences.orders
    AFTER UPDATE
    AS
BEGIN
    IF ((SELECT cancelled FROM inserted) = 1)
        BEGIN
            EXEC conferences.cancel_order ((SELECT order_id FROM inserted));
        END
END
GO


CREATE TRIGGER conferences.same_conference_day_exists_in_order
    ON conferences.conference_day_order_item
    AFTER INSERT
    AS
BEGIN
    IF (SELECT count(*)
              FROM conferences.conference_day_order_item cdoi
              WHERE cdoi.order_id = (SELECT order_id FROM inserted)
                AND cdoi.conference_day_id = (SELECT conference_day_id FROM inserted)) > 1
        BEGIN
            THROW 50001, 'Conference day with given ID already exists in the order', 1;
        END
END
GO

CREATE TRIGGER conferences.remove_attendee_if_neccessary
    ON conferences.conference_day_attendee
    AFTER DELETE
    AS
BEGIN
    IF NOT EXISTS(SELECT *
                  FROM conferences.conference_day_attendee cda
                  WHERE cda.attendee_id = (SELECT attendee_id FROM inserted)
                    AND cda.conference_day_order_item_id <> (SELECT conference_day_order_item_id FROM inserted))
        BEGIN
            IF EXISTS(SELECT *
                      FROM conferences.student_attendee sa
                      WHERE sa.attendee_id = (SELECT attendee_id FROM inserted))
                BEGIN
                    DELETE sa
                    FROM conferences.student_attendee sa
                    WHERE sa.attendee_id = (SELECT attendee_id FROM inserted);
                END

            DELETE a FROM conferences.attendee a WHERE a.attendee_id = (SELECT attendee_id FROM inserted);
        END
END
GO


CREATE TRIGGER conferences.remove_conference_day_attendee_after_remove_conference_day_order_item
    ON conferences.conference_day_order_item
    AFTER DELETE
    AS
BEGIN
    DELETE cda
    FROM conferences.conference_day_attendee cda
    WHERE cda.conference_day_order_item_id = (SELECT conference_day_order_item_id FROM inserted);
END
GO


CREATE TRIGGER conferences.remove_workshop_attendee_after_remove_workshop_order_item
    ON conferences.workshop_order_item
    AFTER DELETE
    AS
BEGIN
    DELETE wa
    FROM conferences.workshop_attendee wa
    WHERE wa.workshop_order_item_id = (SELECT workshop_order_item_id FROM inserted);
END
GO


CREATE TRIGGER conferences.remove_workshop_attendee_after_remove_conference_day_attendee
    ON conferences.conference_day_attendee
    AFTER DELETE
    AS
BEGIN
    DELETE wa
    FROM conferences.workshop_attendee wa
    WHERE wa.conference_day_attendee_id = (SELECT conference_day_attendee_id FROM inserted);
END
GO

CREATE TRIGGER conferences.remove_workshop_order_item_after_last_workshop_attendee_removed
    ON conferences.workshop_attendee
    AFTER DELETE
    AS
BEGIN
    IF EXISTS(SELECT *
              FROM conferences.workshop_attendee wa
              WHERE wa.workshop_order_item_id = (SELECT workshop_order_item_id FROM inserted)
                AND wa.workshop_attendee_id <> (SELECT workshop_attendee_id FROM inserted))
        BEGIN
            DELETE woi
            FROM conferences.workshop_order_item woi
            WHERE woi.workshop_order_item_id = (SELECT workshop_order_item_id FROM inserted);
        END
END
GO


CREATE TRIGGER conferences.order_workshop_only_if_ordered_proper_conference_day
    ON conferences.workshop_order_item
    AFTER INSERT
    AS
BEGIN
    IF NOT EXISTS(SELECT *
                  FROM conferences.conference_day_order_item cdoi
                           JOIN conference_day cd on cdoi.conference_day_id = cd.conference_day_id
                           JOIN workshop w on cd.conference_day_id = w.conference_day_id
                  WHERE w.workshop_id = (SELECT workshop_id FROM inserted)
                    AND cdoi.conference_day_order_item_id = (SELECT conference_day_order_item_id FROM inserted))
        BEGIN
            THROW 50001, 'Cannot order workshop on not ordered conference day', 1;
        END
END
GO

CREATE TRIGGER conferences.workshop_overlapping
    ON conferences.workshop_attendee
    AFTER INSERT
    AS
BEGIN
    DECLARE @attendee_id INT;
    SET @attendee_id = (SELECT cda.attendee_id
                        FROM conferences.conference_day_attendee cda
                        WHERE cda.conference_day_attendee_id = (SELECT conference_day_attendee_id FROM inserted));

    DECLARE @workshop_start DATETIME
    SET @workshop_start = (SELECT w.date_start
                           FROM conferences.workshop_order_item woi
                                    JOIN conferences.workshop w ON woi.workshop_id = w.workshop_id
                           WHERE woi.workshop_order_item_id = (SELECT workshop_order_item_id FROM inserted));

    DECLARE @workshop_end DATETIME
    SET @workshop_end = (SELECT w.date_end
                         FROM conferences.workshop_order_item woi
                                  JOIN conferences.workshop w ON woi.workshop_id = w.workshop_id
                         WHERE woi.workshop_order_item_id = (SELECT workshop_order_item_id FROM inserted));

    IF EXISTS(SELECT *
              FROM conferences.workshop_attendee wa
                       JOIN conferences.workshop_order_item woi
                            ON wa.workshop_order_item_id = woi.workshop_order_item_id
                       JOIN conferences.workshop w ON woi.workshop_id = w.workshop_id
                       JOIN conferences.conference_day_attendee cda
                            ON wa.conference_day_attendee_id = cda.conference_day_attendee_id
              WHERE cda.attendee_id = @attendee_id
                AND ((@workshop_start > w.date_start AND @workshop_start < w.date_end) OR
                     (@workshop_start < w.date_start AND @workshop_end > w.date_start)))
        BEGIN
            THROW 50001, 'Attendee particapate already in workshop which is at the same time', 1;
        END
END
GO