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
 /* Filename  : xyz.c                                                        */
 /* Author    : Todd White                                                   */
 /* Revision  : 1.0                                                          */
 /* Updated   : 19-May-07                                                    */
 /*                                                                          */
 /* This file contains support for the A/D Converter (ADC) subsystem of the  */
 /* TMS320LF2407A DSP.                                                       */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* Revision Log:                                                            */
 /*                                                                          */
 /* Rev 1.0  : 19-May-07, trw -- File created.                               */
 /* ------------------------------------------------------------------------ */
 
 /* ------------------------------------------------------------------------ */
 /* The following excerpt is designed to illustrate the use of the Coverage  */
 /* Marks. These marks are used by the Coverage Analysis Management System.  */
 /* ------------------------------------------------------------------------ */
 #if 0   /* Intentionally disabled - CAMS test only */
 
 void DisplayFunction (void)
 {
 }
 
 /* Generate an IMARK */
 void TestFunction (void)
 {
 }
 
 #endif
 
 #include "sysdefs.h"
 // #include "ti2407a.h"
 // #include "serial.h"
 // #include "event.h"
 #include "adc.h"
 
 /* ------------------------------------------------------------------------ */
 /* Module Constants and Definitions                                         */
 /* ------------------------------------------------------------------------ */
 
 #define THRESH_MSECS        2 /* Threshold processing interval */
 
 #define REPORT_MSECS     5000 /* Statistics reporting interval */
 
 /* ------------------------------------------------------------------------ */
 /* Conversion Result Values                                                 */
 /* ------------------------------------------------------------------------ */
 
 static bool ADC_Valid = FALSE; /* General validity flag for A/D subsystem */
 
 #define NUM_SAMPLES 10 /* Samples used for averaging */
 
 static struct
 {
   word Value [NUM_SAMPLES];
 
 } ADC_Data [NUM_ADC_INPUTS];
 
 static word ADC_Cnt = 0;
 
 /* ------------------------------------------------------------------------ */
 /* Threshold Detection State Machine Structure and Related Objects          */
 /* ------------------------------------------------------------------------ */
 
 enum { THRESH_DSBLD, THRESH_NULL, THRESH_MAYBE_ACTV,
 
        THRESH_ACTV , THRESH_MAYBE_INACTV };
 
 static struct
 {
    byte State;
 
    word ThreshVal;
 
    bool PosLogic;
 
    word Timer;
 
    word ActvMsecs;
 
    word InactvMsecs;
 
 } ADC_Thresh [NUM_ADC_INPUTS];
 
 
 /* ------------------------------------------------------------------------ */
 /* ADC_GetAvg  -  Returns Average Value for Specified A/D Channel           */
 /* ------------------------------------------------------------------------ */
 
 word ADC_GetAvg (byte Chan)
 {
    byte i;
 
    word Total;
 
    if ((ADC_Cnt == 0) || (! ADC_Valid)) return (0); /* Exit if not valid */
 
 
    for (i = 0, Total = 0; i < ADC_Cnt; i++)
    {
       Total += ADC_Data[Chan].Value[i];
    }
 
    return ((Total + (ADC_Cnt / 2)) / ADC_Cnt);
 }
 
 
 /* ------------------------------------------------------------------------ */
 /* ADC_RunThresh  -  Run Threshold Detection State Machines                 */
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* This routine runs threshold detection state machine logic for all A/D    */
 /* channels that have been set up for this operation.                       */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 static void ADC_RunThresh (void)
 {
    byte i;
 
    bool InRange;
 
    /* --------------------------------------------------------------------- */
    /* Run through the channel table and process all channels that are not   */
    /* in the "Disabled" state.                                              */
    /* --------------------------------------------------------------------- */
 
    for (i = 0; i < NUM_ADC_INPUTS; i++) /* For each channel */
 
    {
       if (ADC_Thresh[i].State != THRESH_DSBLD) /* If detection active */
       {
          /* --------------------------------------------------------------- */
          /* Determine whether the latest value is "In" or "Out" of the      */
          /* specified channel Threshold range.                              */
          /* --------------------------------------------------------------- */
 		 
          InRange = (bool)(((ADC_Thresh[i].PosLogic) &&
                                (ADC_GetAvg(i) >= ADC_Thresh[i].ThreshVal)) ||
 
                         ((! ADC_Thresh[i].PosLogic) &&
                                (ADC_GetAvg(i) <= ADC_Thresh[i].ThreshVal)));
 
          switch (ADC_Thresh[i].State)
          {
             case THRESH_NULL :
 
                /* --------------------------------------------------------- */
                /* If the channel is in the threshold range, start the timer */
                /* used for validation, and go to the "Maybe Active" state.  */
                /* --------------------------------------------------------- */
 			
                if (InRange)
                {
                   ADC_Thresh[i].State = THRESH_MAYBE_ACTV;
 
                   ADC_Thresh[i].Timer = Sys1Msec16;
                }
 
                break;
 
             case THRESH_MAYBE_ACTV :
 
                /* --------------------------------------------------------- */
                /* If the channel is no longer in the threshold range, go    */
                /* back to the "Null" state. Otherwise see if the validation */
                /* interval has expired. If so, go to the "Active" state.    */
                /* --------------------------------------------------------- */
 
                if (! InRange) /* If no longer active */
                {
                   ADC_Thresh[i].State = THRESH_NULL;
                }
                else if ((Sys1Msec16 - ADC_Thresh[i].Timer) >=
                                                      ADC_Thresh[i].ActvMsecs)
                {
                   ADC_Thresh[i].State = THRESH_ACTV;
                }
 
                break;
 
             case THRESH_ACTV :
 
                /* --------------------------------------------------------- */
                /* If the channel is no longer in the threshold range, go to */
                /* the "Maybe Inactive" state. Otherwise there is no State   */
                /* change.                                                   */
                /* --------------------------------------------------------- */
 
                if (! InRange)
                {
                   ADC_Thresh[i].State = THRESH_MAYBE_INACTV;
 
                   ADC_Thresh[i].Timer = Sys1Msec16;
                }
 
                break;
 
             case THRESH_MAYBE_INACTV :
 
                /* --------------------------------------------------------- */
                /* If the channel is back in the threshold range again, go   */
                /* right back to the "Active" state. Otherwise, if the       */
                /* validation time has expired, go back to the "Null" State. */
                /* --------------------------------------------------------- */
 			   
                if (InRange) /* If active again */
                {
                   /* CNOTE: Transitional State Only */
 
                   ADC_Thresh[i].State = THRESH_ACTV;
                }
                else if ((Sys1Msec16 - ADC_Thresh[i].Timer) >=
                                                    ADC_Thresh[i].InactvMsecs)
                {
                   ADC_Thresh[i].State = THRESH_NULL;
                }
 
                break;
 
             default: /* Other */
 	
                /* CNOTE: Severe Malfunction Only */
 
                SYS_Event (BAD_CASE_VALUE);
 
                break;
          }
       }
    }
 }
 
 
 /* ------------------------------------------------------------------------ */
 /* ADC_IsChanActv  -  Returns TRUE if Spcfd A/D Channel is at Active State  */
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* This routine returns TRUE if the specified A/D channel has been enabled  */
 /* for Threshold detection and is currently in the Active state.            */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 bool ADC_IsChanActv (byte Chan)
 {
    return ((bool)(ADC_Valid &&
                          ((ADC_Thresh[Chan].State == THRESH_ACTV) ||
                           (ADC_Thresh[Chan].State == THRESH_MAYBE_INACTV))));
 }
 
 
 /* ------------------------------------------------------------------------ */
 /* ADC_SetChanThresh  -  Set Threshold for A/D Chan and Start Detection     */
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* This routine is used to initiate threshold detection on a specified A/D  */
 /* channel. The caller specifies the channel index, the threshold value as  */
 /* a digital number, the polarity of the threshold detection (above or      */
 /* below the specified digital value), and the time in msecs to be used for */
 /* validation of "in" and "out" of threshold range.                         */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 void ADC_SetChanThresh (byte Chan, word Thresh,
                                 bool Postv, word ActvMsecs, word InactvMsecs)
 {
    ADC_Thresh[Chan].State       = THRESH_DSBLD; /* Disable while changing */
 
    ADC_Thresh[Chan].ThreshVal   = Thresh;
 
    ADC_Thresh[Chan].PosLogic    = Postv;
 
    ADC_Thresh[Chan].ActvMsecs   = ActvMsecs;
 
    ADC_Thresh[Chan].InactvMsecs = InactvMsecs;
 
    ADC_Thresh[Chan].State       = THRESH_NULL; /* Start detection */
 }
 
 
 /* ------------------------------------------------------------------------ */
 /* ADC_SetNewThresh  -  Set New Threshold for A/D Chan with No State Change */
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* This routine is used to move the threshold for a specified A/D channel   */
 /* without disrupting the state logic. The caller specifies the channel     */
 /* index, and the new threshold value. The rest of the channel settings are */
 /* left intact.                                                             */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 void ADC_SetNewThresh (byte Chan, word Thresh)
 {
    ADC_Thresh[Chan].ThreshVal = Thresh;
 }
 
 
 /* ------------------------------------------------------------------------ */
 /* ADC_Svc  -  A/D Converter Subsystem Service                              */
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* This routine is invoked by the main task loop at a rate sufficient for   */
 /* servicing the A/D Converter (ADC) subsystem. The routine maintains its   */
 /* own timers and is responsible for triggering "Autoconvert" cycles at a   */
 /* high enough rate to satisfy the highest required sample rate for the     */
 /* system. When an "Autoconvert" is completed, this routine posts the new   */
 /* sample values in global variables for use by the system components that  */
 /* utilize the various sample streams. Note that there is no queueing of    */
 /* sample values at this level. It is up to the consuming process to read   */
 /* the values and deal with them as they see fit.                           */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 void ADC_Svc (void)
 {
    static bool Init = FALSE, ADC_Timeout = FALSE;
 
    static word Nxt, TimeoutTimer, ReportTimer, ThreshTimer;
    
    static ulong ValidCnt, ErrorCnt;
 
    byte i;
 
    volatile word * pRESULTS;
 
    /* --------------------------------------------------------------------- */
    /* The "Init" flag is used to prevent conversions from running until the */
    /* main task loop has begun to execute. The first invocation of this     */
    /* routine causes the the one-time setup to be performed, and the first  */
    /* conversion cycle to be initiated.                                     */
    /* --------------------------------------------------------------------- */
 
    if (! Init) /* If first invocation */
    {
       SCSR1    |= 0x0080; /* ADC CLKEN */
 
       ADCTRL1   = 0x2f90; /* Soft Stop, Start-Stop mode, Cascade SEQ1/2 */
 
       ADCTRL2   = 0x4200; /* Reset SEQ1, Clear INT FLAG SEQ1 */
 
       /* ------------------------------------------------------------------ */
       /* Note that "MAXCONV" limits the number of actual conversions, but   */
       /* the "CHSELSEQn" registers are set to simply select all 15 of the   */
       /* A/D input channels in order. This can be adjusted once the system  */
       /* requirements are better defined.                                   */
       /* ------------------------------------------------------------------ */
 
       MAXCONV   = NUM_ADC_INPUTS - 1; /* Set number of conversions */
 
       CHSELSEQ1 = 0x3210; /* First 4 conversion sources */
 
       CHSELSEQ2 = 0x7654; /* Next  4 conversion sources */
 
       CHSELSEQ3 = 0xba98; /* Next  4 conversion sources */
 
       CHSELSEQ4 = 0xfedc; /* Next  4 conversion sources */
 
       Init = TRUE; ErrorCnt = ValidCnt = 0;
 
       TimeoutTimer = ReportTimer = ThreshTimer = Sys1Msec16;
 
       ADC_Cnt = Nxt = 0;
 
       ADCTRL2 |= 0x4200; /* Reset SEQ1, Clear INT FLAG SEQ1 */
 
       ADCTRL2 |= 0x2000; /* Start the first conversion */
 
       return;
    }
 
    /* --------------------------------------------------------------------- */
    /* Check the current conversion for done or timeout. If done, grab the   */
    /* result values, process them, then start a new conversion.             */
    /* --------------------------------------------------------------------- */
 
    if (ADCTRL2 & 0x0200) /* If "INT FLAG SEQ1" (Done Flag) Set */
 
    {
       for (i = 0, pRESULTS = &RESULT0; i < NUM_ADC_INPUTS; i++)
       {
          ADC_Data[i].Value[Nxt] = pRESULTS[i] >> 6; /* Use upper bits */
       }
 
       if (ADC_Cnt < NUM_SAMPLES) ADC_Cnt++; /* Incrmt if Array not full yet */
 
       Nxt = (Nxt + 1) % NUM_SAMPLES; /* Adj Array "Next" index */
 
       ValidCnt++; /* Count successful conversion */
 
       ADC_Valid = TRUE; /* Set "Validity" flag */
 
       TimeoutTimer = Sys1Msec16; /* Restart Timer */
 
       ADCTRL2 |= 0x4200; /* Reset SEQ1, Clear INT FLAG SEQ1 */
 
       ADCTRL2 |= 0x2000; /* Start the next conversion */
    }
    else if ((Sys1Msec16 - TimeoutTimer) >= 2) /* Else If timeout */
    {
       ErrorCnt++; /* Count error */
 
       ADC_Valid = FALSE; /* Clear the "Validity" flag */
 
       if (! ADC_Timeout) /* If first error */
       {
          ADC_Timeout = TRUE; SYS_Event (ADC_CONVERSION_TIMEOUT);
       }
 
       ADC_Cnt = Nxt = 0;
 
       TimeoutTimer = Sys1Msec16; /* Restart Timer */
 
       ADCTRL2 |= 0x4200; /* Reset SEQ1, Clear INT FLAG SEQ1 */
 
       ADCTRL2 |= 0x2000; /* Start the next conversion */
    }
 
    /* --------------------------------------------------------------------- */
    /* Run the A/D Threshold Detect State Machines                           */
    /* --------------------------------------------------------------------- */
 
    if (ADC_Valid && ((Sys1Msec16 - ThreshTimer) >= THRESH_MSECS))
    {
       ThreshTimer = Sys1Msec16; ADC_RunThresh ();
    }
 
    /* --------------------------------------------------------------------- */
    /* If Report interval has expired, show stats and reset counts, etc.     */
    /* --------------------------------------------------------------------- */
 
    if (((Sys1Msec16 - ReportTimer) >= REPORT_MSECS) &&
                                           (SerialTxSpace(TRACE_CHAN) >= 160))
    {
       ReportTimer = Sys1Msec16; /* Reset timer */
 
       ValidCnt = ErrorCnt = 0; /* Reset counters */
    }
 }
 
 
 /* ------------------------------------------------------------------------ */
 /* ADC_Init  -  A/D Converter Subsystem Initialization                      */
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* This routine must be called one time during startup prior to invoking    */
 /* the A/D Service routine.                                                 */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 void ADC_Init (void)
 {
    byte i;
 
    /* --------------------------------------------------------------------- */
    /* Disable Threshold state machines for all channels.                    */
    /* --------------------------------------------------------------------- */
 
    for (i = 0; i < NUM_ADC_INPUTS; i++)
    {
       ADC_Thresh[i].State = THRESH_DSBLD;
    }
 }
 
 
 /* ------------------------------------------------------------------------ */
 /* Is_ADC_Valid  -  Returns TRUE if A/D Subsystem is Operational            */
 /* ------------------------------------------------------------------------ */
 /*                                                                          */
 /* This routine can be used to query the health of the A/D subsystem.       */
 /*                                                                          */
 /* ------------------------------------------------------------------------ */
 
 bool Is_ADC_Valid (void)
 {
    return (ADC_Valid);
 }
 