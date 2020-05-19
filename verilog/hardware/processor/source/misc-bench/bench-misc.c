{\rtf1\ansi\ansicpg1252\cocoartf1671\cocoasubrtf600
{\fonttbl\f0\fmodern\fcharset0 Courier;}
{\colortbl;\red255\green255\blue255;\red38\green38\blue38;\red107\green0\blue1;\red108\green78\blue25;
\red77\green49\blue24;\red51\green37\blue233;\red15\green112\blue1;\red215\green108\blue6;\red0\green17\blue109;
}
{\*\expandedcolortbl;;\cssrgb\c20000\c20000\c20000;\cssrgb\c50196\c0\c0;\cssrgb\c50196\c37647\c12549;
\cssrgb\c37647\c25098\c12549;\cssrgb\c26667\c26667\c93333;\cssrgb\c0\c50196\c0;\cssrgb\c87843\c50196\c0;\cssrgb\c0\c12549\c50196;
}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\sl280\partightenfactor0

\f0\fs24 \cf2 \expnd0\expndtw0\kerning0
\outl0\strokewidth0 \strokec2  \cf3 \strokec3 /* Benchmark for some misc functions\cf2 \strokec2 \
 \cf3 \strokec3    Copyright (C) 2001, 2002 Free Software Foundation, Inc.\cf2 \strokec2 \
 \cf3 \strokec3    Written by Stephane Carrez (stcarrez@nerim.fr)       \cf2 \strokec2 \
 \
 \cf3 \strokec3 This file is free software; you can redistribute it and/or modify it\cf2 \strokec2 \
 \cf3 \strokec3 under the terms of the GNU General Public License as published by the\cf2 \strokec2 \
 \cf3 \strokec3 Free Software Foundation; either version 2, or (at your option) any\cf2 \strokec2 \
 \cf3 \strokec3 later version.\cf2 \strokec2 \
 \
 \cf3 \strokec3 In addition to the permissions in the GNU General Public License, the\cf2 \strokec2 \
 \cf3 \strokec3 Free Software Foundation gives you unlimited permission to link the\cf2 \strokec2 \
 \cf3 \strokec3 compiled version of this file with other programs, and to distribute\cf2 \strokec2 \
 \cf3 \strokec3 those programs without any restriction coming from the use of this\cf2 \strokec2 \
 \cf3 \strokec3 file.  (The General Public License restrictions do apply in other\cf2 \strokec2 \
 \cf3 \strokec3 respects; for example, they cover modification of the file, and\cf2 \strokec2 \
 \cf3 \strokec3 distribution when not linked into another program.)\cf2 \strokec2 \
 \
 \cf3 \strokec3 This file is distributed in the hope that it will be useful, but\cf2 \strokec2 \
 \cf3 \strokec3 WITHOUT ANY WARRANTY; without even the implied warranty of\cf2 \strokec2 \
 \cf3 \strokec3 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU\cf2 \strokec2 \
 \cf3 \strokec3 General Public License for more details.\cf2 \strokec2 \
 \
 \cf3 \strokec3 You should have received a copy of the GNU General Public License\cf2 \strokec2 \
 \cf3 \strokec3 along with this program; see the file COPYING.  If not, write to\cf2 \strokec2 \
 \cf3 \strokec3 the Free Software Foundation, 59 Temple Place - Suite 330,\cf2 \strokec2 \
 \cf3 \strokec3 Boston, MA 02111-1307, USA.  */\cf2 \strokec2 \
 \
 \
 \cf4 \strokec4 #include <benchs.h>\cf2 \strokec2 \
 \cf4 \strokec4 #include <stddef.h>\cf2 \strokec2 \
 \cf4 \strokec4 #include <string.h>\cf2 \strokec2 \
 \
 \cf3 \strokec3 /* Forward declaration.  */\cf2 \strokec2 \
 \cf5 \strokec5 void\cf2 \strokec2  bench_list ({\field{\*\fldinst{HYPERLINK "https://www.gnu.org/software/m68hc11/examples/structbench.html"}}{\fldrslt \cf6 \strokec6 bench_t}} *b);\
 \cf5 \strokec5 void\cf2 \strokec2  bench_strlen ({\field{\*\fldinst{HYPERLINK "https://www.gnu.org/software/m68hc11/examples/structbench.html"}}{\fldrslt \cf6 \strokec6 bench_t}} *b);\
 \cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 short\cf2 \strokec2  fact_ushort (\cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 short\cf2 \strokec2  n);\
 \cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 long\cf2 \strokec2  fact_ulong (\cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 long\cf2 \strokec2  n);\
 \cf5 \strokec5 void\cf2 \strokec2  bench_fact ({\field{\*\fldinst{HYPERLINK "https://www.gnu.org/software/m68hc11/examples/structbench.html"}}{\fldrslt \cf6 \strokec6 bench_t}} *b);\
 \
 \cf3 \strokec3 /* Benchmark the walk of a single linked list having 100 elements.  */\cf2 \strokec2 \
 \cf5 \strokec5 void\cf2 \strokec2 \
 bench_list ({\field{\*\fldinst{HYPERLINK "https://www.gnu.org/software/m68hc11/examples/structbench.html"}}{\fldrslt \cf6 \strokec6 bench_t}} *b)\
 \{\
   \cf7 \strokec7 struct \cf2 \strokec2 list \{\
     \cf7 \strokec7 struct \cf2 \strokec2 list *next;\
   \};\
   \cf7 \strokec7 struct \cf2 \strokec2 list elts[100];\
   \cf7 \strokec7 struct \cf2 \strokec2 list *first;\
   \cf7 \strokec7 struct \cf2 \strokec2 list *n;\
   \cf5 \strokec5 int\cf2 \strokec2  i;\
 \
   \cf3 \strokec3 /* Build the list.  */\cf2 \strokec2 \
   bench_start (b);\
   first = 0;\
   \cf8 \strokec8 for\cf2 \strokec2  (i = 0; i < 100; i++)\
     \{\
       elts[i].next = first;\
       first = &elts[i];\
     \}\
   bench_stop (b);\
   bench_report (b, \cf9 \strokec9 "Single linked list init (100 elts)"\cf2 \strokec2 );\
 \
   \cf3 \strokec3 /* Scan the list.  */\cf2 \strokec2 \
   i = 0;\
   bench_start (b);\
   \cf8 \strokec8 for\cf2 \strokec2  (n = first; n; n = n->next)\
     i++;\
   bench_stop (b);\
   bench_report (b, \cf9 \strokec9 "Scan list %d elts"\cf2 \strokec2 , (\cf5 \strokec5 long\cf2 \strokec2 ) i);\
 \}\
 \
 \cf7 \strokec7 const\cf2 \strokec2  \cf5 \strokec5 char\cf2 \strokec2  *bench_string = \cf9 \strokec9 "Hello World!"\cf2 \strokec2 ;\
 \
 \cf3 \strokec3 /* Benchmark of strlen.  */\cf2 \strokec2 \
 \cf5 \strokec5 void\cf2 \strokec2 \
 bench_strlen ({\field{\*\fldinst{HYPERLINK "https://www.gnu.org/software/m68hc11/examples/structbench.html"}}{\fldrslt \cf6 \strokec6 bench_t}} *b)\
 \{\
   size_t l;\
 \
   \cf3 \strokec3 /* Gcc 3.0 computes the lenght of the string.  Gcc 2.95 does not.  */\cf2 \strokec2 \
   bench_start (b);\
   l = strlen (\cf9 \strokec9 "Hello World!"\cf2 \strokec2 );\
   bench_stop (b);\
   bench_report (b, \cf9 \strokec9 "strlen const string %d"\cf2 \strokec2 , (\cf5 \strokec5 long\cf2 \strokec2 ) l);\
 \
   bench_start (b);\
   l = strlen (bench_string);\
   bench_stop (b);\
   bench_report (b, \cf9 \strokec9 "strlen %d"\cf2 \strokec2 , (\cf5 \strokec5 long\cf2 \strokec2 ) l);  \
 \}\
 \
 \cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 short\cf2 \strokec2 \
 fact_ushort (\cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 short\cf2 \strokec2  n)\
 \{\
   \cf8 \strokec8 if\cf2 \strokec2  (n > 0)\
     \cf8 \strokec8 return\cf2 \strokec2  n * fact_ushort (n - 1);\
   \cf8 \strokec8 else\cf2 \strokec2 \
     \cf8 \strokec8 return\cf2 \strokec2  1;\
 \}\
 \
 \cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 long\cf2 \strokec2 \
 fact_ulong (\cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 long\cf2 \strokec2  n)\
 \{\
   \cf8 \strokec8 if\cf2 \strokec2  (n > 0)\
     \cf8 \strokec8 return\cf2 \strokec2  n * fact_ulong (n - 1);\
   \cf8 \strokec8 else\cf2 \strokec2 \
     \cf8 \strokec8 return\cf2 \strokec2  1;\
 \}\
 \
 \cf5 \strokec5 void\cf2 \strokec2 \
 bench_fact ({\field{\*\fldinst{HYPERLINK "https://www.gnu.org/software/m68hc11/examples/structbench.html"}}{\fldrslt \cf6 \strokec6 bench_t}} *b)\
 \{\
   \cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 short\cf2 \strokec2  f;\
   \cf5 \strokec5 unsigned\cf2 \strokec2  \cf5 \strokec5 long\cf2 \strokec2  fl;\
   \
   bench_start (b);\
   f = fact_ushort (8);\
   bench_stop (b);\
   bench_report (b, \cf9 \strokec9 "fact(8) unsigned short (%d)"\cf2 \strokec2 , (\cf5 \strokec5 long\cf2 \strokec2 ) f);\
 \
   bench_start (b);\
   fl = fact_ulong (12);\
   bench_stop (b);\
   bench_report (b, \cf9 \strokec9 "fact(12) unsigned long (%d)"\cf2 \strokec2 , fl);\
 \}\
 \
 \cf3 \strokec3 /* Main, run the benchmarks.  */\cf2 \strokec2 \
 \cf5 \strokec5 int\cf2 \strokec2 \
 main ()\
 \{\
   {\field{\*\fldinst{HYPERLINK "https://www.gnu.org/software/m68hc11/examples/structbench.html"}}{\fldrslt \cf6 \strokec6 bench_t}} b;\
 \
   bench_init (&b);\
   bench_list (&b);\
   bench_strlen (&b);\
   bench_fact (&b);\
   \cf8 \strokec8 return\cf2 \strokec2  0;\
 \}\
}
