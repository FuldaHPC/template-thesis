#include <stddef.h>
#include <omp.h>

double parallel_sum(const double *values, size_t count)
{
    double sum = 0.0;

    #pragma omp parallel for reduction(+:sum) schedule(static)
    for (size_t i = 0; i < count; ++i) {
        sum += values[i];
    }

    return sum;
}
