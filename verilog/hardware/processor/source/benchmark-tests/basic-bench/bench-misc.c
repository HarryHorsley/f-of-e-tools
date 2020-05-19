 /* Benchmark for some misc functions
    Copyright (C) 2001, 2002 Free Software Foundation, Inc.
    Written by Stephane Carrez (stcarrez@nerim.fr)       
 
 This file is free software; you can redistribute it and/or modify it
 under the terms of the GNU General Public License as published by the
 Free Software Foundation; either version 2, or (at your option) any
 later version.
 
 In addition to the permissions in the GNU General Public License, the
 Free Software Foundation gives you unlimited permission to link the
 compiled version of this file with other programs, and to distribute
 those programs without any restriction coming from the use of this
 file.  (The General Public License restrictions do apply in other
 respects; for example, they cover modification of the file, and
 distribution when not linked into another program.)
 
 This file is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; see the file COPYING.  If not, write to
 the Free Software Foundation, 59 Temple Place - Suite 330,
 Boston, MA 02111-1307, USA.  */
 
 
 #include <benchs.h>
 #include <stddef.h>
 #include <string.h>
 
 /* Forward declaration.  */
 void bench_list (bench_t *b);
 void bench_strlen (bench_t *b);
 unsigned short fact_ushort (unsigned short n);
 unsigned long fact_ulong (unsigned long n);
 void bench_fact (bench_t *b);
 
 /* Benchmark the walk of a single linked list having 100 elements.  */
 void
 bench_list (bench_t *b)
 {
   struct list {
     struct list *next;
   };
   struct list elts[100];
   struct list *first;
   struct list *n;
   int i;
 
   /* Build the list.  */
   bench_start (b);
   first = 0;
   for (i = 0; i < 100; i++)
     {
       elts[i].next = first;
       first = &elts[i];
     }
   bench_stop (b);
   bench_report (b, "Single linked list init (100 elts)");
 
   /* Scan the list.  */
   i = 0;
   bench_start (b);
   for (n = first; n; n = n->next)
     i++;
   bench_stop (b);
   bench_report (b, "Scan list %d elts", (long) i);
 }
 
 const char *bench_string = "Hello World!";
 
 /* Benchmark of strlen.  */
 void
 bench_strlen (bench_t *b)
 {
   size_t l;
 
   /* Gcc 3.0 computes the lenght of the string.  Gcc 2.95 does not.  */
   bench_start (b);
   l = strlen ("Hello World!");
   bench_stop (b);
   bench_report (b, "strlen const string %d", (long) l);
 
   bench_start (b);
   l = strlen (bench_string);
   bench_stop (b);
   bench_report (b, "strlen %d", (long) l);  
 }
 
 unsigned short
 fact_ushort (unsigned short n)
 {
   if (n > 0)
     return n * fact_ushort (n - 1);
   else
     return 1;
 }
 
 unsigned long
 fact_ulong (unsigned long n)
 {
   if (n > 0)
     return n * fact_ulong (n - 1);
   else
     return 1;
 }
 
 void
 bench_fact (bench_t *b)
 {
   unsigned short f;
   unsigned long fl;
   
   bench_start (b);
   f = fact_ushort (8);
   bench_stop (b);
   bench_report (b, "fact(8) unsigned short (%d)", (long) f);
 
   bench_start (b);
   fl = fact_ulong (12);
   bench_stop (b);
   bench_report (b, "fact(12) unsigned long (%d)", fl);
 }
 
 /* Main, run the benchmarks.  */
 int
 main ()
 {
   bench_t b;
 
   bench_init (&b);
   bench_list (&b);
   bench_strlen (&b);
   bench_fact (&b);
   return 0;
 }
