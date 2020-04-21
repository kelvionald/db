create table public.reader
(
    reader_id serial not null
        constraint reader_pk
            primary key,
    firstname varchar(100),
    lastname  varchar(100),
    read_num  integer,
    birthday  date
);

alter table public.reader
    owner to postgres;

create table public.book
(
    book_id          serial not null
        constraint book_pk
            primary key,
    isbn             varchar(13),
    name             varchar(200),
    page_num         integer,
    publication_year integer
);

alter table public.book
    owner to postgres;

create table public.author
(
    author_id serial not null
        constraint author_pk
            primary key,
    firstname varchar(100),
    lastname  varchar(100),
    book_num  integer,
    birthday  date
);

alter table public.author
    owner to postgres;

create table public.author_has_book
(
    author_has_book_id serial not null
        constraint author_has_book_pk
            primary key,
    author_id          integer
        constraint author_id
            references public.author,
    book_id            integer
        constraint book_id
            references public.book
);

alter table public.author_has_book
    owner to postgres;

create table public.copy
(
    copy_id        serial not null
        constraint copy_pk
            primary key,
    book_id        integer
        constraint book_id
            references public.book,
    number         integer,
    admission_date date
);

alter table public.copy
    owner to postgres;

create table public.issuance
(
    issuance_id   serial not null
        constraint issuance_pk
            primary key,
    copy_id       integer
        constraint copy_id
            references public.copy,
    reader_id     integer
        constraint reader_id
            references public.reader,
    issue_date    date,
    release_date  date,
    deadline_date date
);

alter table public.issuance
    owner to postgres;

