/* MTI_DPI */

/*
 * Copyright 2002-2010 Mentor Graphics Corporation.
 *
 * Note:
 *   This file is automatically generated.
 *   Please do not edit this file - you will lose your edits.
 *
 * Settings when this file was generated:
 *   PLATFORM = 'win32pe'
 */
#ifndef INCLUDED_SYN_DPI
#define INCLUDED_SYN_DPI

#ifdef __cplusplus
#define DPI_LINK_DECL  extern "C" 
#else
#define DPI_LINK_DECL 
#endif

#include "svdpi.h"


DPI_LINK_DECL DPI_DLLESPEC
int
syn_abs(
    int num);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_acos(
    double rTheta);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_asin(
    double rTheta);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_atan(
    double rTheta);

DPI_LINK_DECL DPI_DLLESPEC
void
syn_calc_complex_abs(
    int size,
    const svOpenArrayHandle arry_real,
    const svOpenArrayHandle arry_im);

DPI_LINK_DECL DPI_DLLESPEC
void
syn_calc_fft(
    int num_samples,
    const svOpenArrayHandle data_in_arry,
    const svOpenArrayHandle data_out_re_arry,
    const svOpenArrayHandle data_out_im_arry);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_calc_shade(
    int distance,
    int norm,
    int color);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_cos(
    double rTheta);

DPI_LINK_DECL DPI_DLLESPEC
int
syn_dump_ppm(
    const char* fname,
    int width,
    int depth,
    const svOpenArrayHandle red,
    const svOpenArrayHandle green,
    const svOpenArrayHandle blue);

DPI_LINK_DECL DPI_DLLESPEC
int
syn_dump_raw(
    const char* fname,
    int width,
    int depth,
    const svOpenArrayHandle red,
    const svOpenArrayHandle green,
    const svOpenArrayHandle blue);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_log(
    double rVal);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_log10(
    double rVal);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_sin(
    double rTheta);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_sqrt(
    double rVal);

DPI_LINK_DECL DPI_DLLESPEC
double
syn_tan(
    double rTheta);

#endif 