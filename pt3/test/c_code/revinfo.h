 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 /* ------------------------------------------------------------------------ */
 /* NOTICE: All rights reserved.  This material contains  the trade  secrets */
 /* and confidential  information  of  xxxxxxxxx  Corporation, which  embody */
 /* substantial  creative  effort, ideas  and expressions.  No part  of this */
 /* material may  be reproduced or transmitted  in any form or by any means, */
 /* electronic, mechanical, optical or otherwise, including photocopying and */
 /* recording  or in connection  with any information  storage or  retrieval */
 /* system, without specific written permission from xxxxxxxxx Corporation.  */
 /* ------------------------------------------------------------------------ */
 
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* Filename  : revinfo.h                                                    */
 /* Author    : Todd White                                                   */
 /* Revision  : 1.8                                                          */
 /* Updated   : 18-May-05                                                    */
 /*                                                                          */
 /* This file contains system revision and time stamping information.        */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* Revision Log:                                                            */
 /*                                                                          */
 /* Rev 1.0  : 30-Jun-04, trw -- Original version created.                   */
 /*                                                                          */
 /* Rev 1.1  : 21-Apr-05, trw -- Added build date and time stamps.           */
 /*                                                                          */
 /* Rev 1.2  : 27-Apr-05, trw -- Revved up to 0.141 Beta.  This rev fixes     */
 /*          : PRs #123, #124, and #127.                                     */
 /*                                                                          */
 /* Rev 1.3  : 28-Apr-05, trw -- Rev to 0.142. Update ADC.C and MAIN.C.      */
 /*                                                                          */
 /* Rev 1.4  : 02-May-05, trw -- Rev to 0.143. Update all C files w/ CNOTE.  */
 /*                                                                          */
 /* Rev 1.5  : 07-May-05, trw -- Rev to 0.144. Replaced "CNOTE CFI" with     */
 /*          : "IMARK CFI".                                                  */
 /*                                                                          */
 /* Rev 1.6  : 10-May-05, trw -- Reworked "CMARK", "CNOTE" and "IMARK".      */
 /*                                                                          */
 /* Rev 1.7  : 18-May-05, trw -- Revved to 0.146 Beta.  Fixes for PRs #127,   */
 /*          : #140, #139, #138, and #134.                                   */
 /*                                                                          */
 /* Rev 1.8  : 19-May-05, trw -- Revved to 0.147 Beta.  Fix for powerfail     */
 /*          : recovery glitch.                                              */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 #define REVINFO "Rev 1.000 of 19-May-05"
 
 #define BUILD_DATE __DATE__
 #define BUILD_TIME __TIME__
 