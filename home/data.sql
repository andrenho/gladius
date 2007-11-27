create table paragraphs
           ( helper integer primary key autoincrement
           , book numeric
	   , chapter numeric
	   , verse numeric
	   , bop numeric default 0
	   , eop numeric default 0);

attach database [kjv.bible]
             as kjv;

insert into paragraphs ( book, chapter, verse )
     select book
          , chapter
	  , verse 
       from kjv.bible;

detach database kjv;

create trigger paragraphs_tr
	 after update
            on paragraphs
	  when new.bop = 1
         begin
	        update paragraphs
		   set eop = 1
		 where helper = new.helper - 1;
	   end;

create trigger paragraphs_tr2
	 after update
            on paragraphs
	  when new.bop = 0
         begin
	        update paragraphs
		   set eop = 0
		 where helper = new.helper - 1;
	   end;

create unique index paragraphs_pk
                 on paragraphs
                  ( book ASC
                  , chapter ASC
                  , verse ASC);

update paragraphs
   set bop = 1
 where verse = 1;
