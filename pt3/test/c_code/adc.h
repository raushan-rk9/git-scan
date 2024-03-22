 /*
    2  * Copyright (c) 2016, Texas Instruments Incorporated
    3  * All rights reserved.
    4  *
    5  * Redistribution and use in source and binary forms, with or without
    6  * modification, are permitted provided that the following conditions
    7  * are met:
    8  *
    9  * *  Redistributions of source code must retain the above copyright
   10  *    notice, this list of conditions and the following disclaimer.
   11  *
   12  * *  Redistributions in binary form must reproduce the above copyright
   13  *    notice, this list of conditions and the following disclaimer in the
   14  *    documentation and/or other materials provided with the distribution.
   15  *
   16  * *  Neither the name of Texas Instruments Incorporated nor the names of
   17  *    its contributors may be used to endorse or promote products derived
   18  *    from this software without specific prior written permission.
   19  *
   20  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   21  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   22  * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   23  * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   24  * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   25  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   26  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
   27  * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   28  * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
   29  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
   30  * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
   31  */
#ifndef ti_drivers_ADC__include
#define ti_drivers_ADC__include

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#define ADC_CMD_RESERVED           (32)

#define ADC_STATUS_RESERVED        (-32)

#define ADC_STATUS_SUCCESS         (0)

#define ADC_STATUS_ERROR           (-1)

#define ADC_STATUS_UNDEFINEDCMD    (-2)

/* Add ADC_CMD_<commands> here */

typedef struct ADC_Config_    *ADC_Handle;

typedef struct ADC_Params_ {
    void    *custom;        
    bool    isProtected;    
} ADC_Params;

typedef void (*ADC_CloseFxn) (ADC_Handle handle);

typedef int_fast16_t (*ADC_ControlFxn) (ADC_Handle handle, uint_fast16_t cmd,
    void *arg);

typedef int_fast16_t (*ADC_ConvertFxn) (ADC_Handle handle, uint16_t *value);

typedef uint32_t (*ADC_ConvertRawToMicroVolts) (ADC_Handle handle,
    uint16_t rawAdcValue);

typedef void (*ADC_InitFxn) (ADC_Handle handle);

typedef ADC_Handle (*ADC_OpenFxn) (ADC_Handle handle, ADC_Params *params);

typedef struct ADC_FxnTable_ {
    ADC_CloseFxn      closeFxn;

    ADC_ControlFxn    controlFxn;

    ADC_ConvertFxn    convertFxn;

    ADC_ConvertRawToMicroVolts convertRawToMicroVolts;

    ADC_InitFxn       initFxn;

    ADC_OpenFxn       openFxn;
} ADC_FxnTable;

typedef struct ADC_Config_ {
    ADC_FxnTable const *fxnTablePtr;

    void               *object;

    void         const *hwAttrs;
} ADC_Config;

extern void ADC_close(ADC_Handle handle);

extern int_fast16_t ADC_control(ADC_Handle handle, uint_fast16_t cmd,
    void *arg);

extern int_fast16_t ADC_convert(ADC_Handle handle, uint16_t *value);

extern uint32_t ADC_convertRawToMicroVolts(ADC_Handle handle,
    uint16_t rawAdcValue);

extern void ADC_init(void);

extern ADC_Handle ADC_open(uint_least8_t index, ADC_Params *params);

extern void ADC_Params_init(ADC_Params *params);

#ifdef __cplusplus
}
#endif

#endif /* ti_drivers_ADC__include */
