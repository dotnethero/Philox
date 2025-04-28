#include <curanddx.hpp>
#include <iostream>
#include <vector>
#include <chrono>
#include <thread>
#include <cmath>
#include <iomanip>

using RNG = decltype(
    curanddx::Generator<curanddx::philox4_32>() +
    curanddx::PhiloxRounds<10>() +  // Use 10 rounds for better quality
    curanddx::SM<890>() +           // Target RTX 40-series GPU
    curanddx::Thread());            // Thread-level execution

template<class RNG>
__global__ void generate_kernel(
    float4* d_out,
    const unsigned long long seed,
    const typename RNG::offset_type offset,
    const size_t size) {
        
    const size_t i = blockDim.x * blockIdx.x + threadIdx.x;
    if (i >= size / 4) {
        return;
    }

    // Initialize RNG state with seed and offset
    RNG rng(seed, ((offset + i) % 65536), ((offset + i) / 65536));

    // Use uniform distribution [0,1)
    curanddx::uniform<float> dist(0.0f, 1.0f);

    // Generate 4 numbers at once and store to global memory
    d_out[i] = dist.generate4(rng);
}

int main() {
    const size_t NUM_ELEMENTS = 1000000000ULL;  // 1 billion elements
    const size_t BUFFER_SIZE = NUM_ELEMENTS * sizeof(float);
    
    // Allocate device memory
    float* d_out = nullptr;
    cudaError_t err = cudaMalloc(&d_out, BUFFER_SIZE);
    if (err != cudaSuccess) {
        std::cerr << "Failed to allocate device memory: " << cudaGetErrorString(err) << std::endl;
        return 1;
    }

    // Setup kernel launch parameters
    const unsigned int BLOCK_SIZE = 256;
    const unsigned int NUM_BLOCKS = (NUM_ELEMENTS / 4 + BLOCK_SIZE - 1) / BLOCK_SIZE;
    
    // Random seed
    const unsigned long long seed = 12345ULL;
    const typename RNG::offset_type offset = 0ULL;

    // Create CUDA events for timing
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Prepare for multiple runs
    const int NUM_RUNS = 10;
    std::vector<float> timings(NUM_RUNS);
    
    for (int run = 0; run < NUM_RUNS; run++) {
        // Record start event
        cudaEventRecord(start);
        
        // Launch kernel
        generate_kernel<RNG><<<NUM_BLOCKS, BLOCK_SIZE>>>((float4*)d_out, seed + run, offset, NUM_ELEMENTS);
        
        // Record stop event
        cudaEventRecord(stop);
        cudaEventSynchronize(stop);
        
        // Calculate elapsed time
        cudaEventElapsedTime(&timings[run], start, stop);
        
        // Check for kernel launch errors
        err = cudaGetLastError();
        if (err != cudaSuccess) {
            std::cerr << "Kernel launch failed: " << cudaGetErrorString(err) << std::endl;
            cudaFree(d_out);
            return 1;
        }
    }

    // Calculate statistics
    float sum = 0.0f;
    for (float t : timings) {
        sum += t;
    }
    float mean = sum / NUM_RUNS;

    float variance = 0.0f;
    for (float t : timings) {
        variance += (t - mean) * (t - mean);
    }
    variance /= NUM_RUNS;
    float stddev = std::sqrt(variance);

    // Print performance statistics
    std::cout << "Performance Statistics:" << std::endl;
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "Average time: " << mean << " ms" << std::endl;
    std::cout << "Standard deviation: " << stddev << " ms" << std::endl;

    // Cleanup timing events
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    // Optional: Verify first few numbers
    std::vector<float> h_verify(1000);
    cudaMemcpy(h_verify.data(), d_out, 1000 * sizeof(float), cudaMemcpyDeviceToHost);
    
    std::cout << "First 10 random numbers generated:" << std::endl;
    for (int i = 0; i < 10; i++) {
        std::cout << h_verify[i] << " ";
    }
    std::cout << std::endl;

    // Cleanup
    cudaFree(d_out);
    return 0;
} 