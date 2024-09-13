import time
import threading
import multiprocessing
import math
import random
from typing import Callable
import sys


def load(v: int) -> float:
    result = 0.0
    for i in range(v):
        for j in range(v):
            result += math.sin(i) * math.cos(j) * math.sqrt(i**2 + j**2)
    return result


def test_st(v: int) -> float:
    start_time = time.time()
    load(v)
    end_time = time.time()
    return end_time - start_time


def test_mt(v: int, num_threads: int) -> float:
    def worker() -> None:
        load(v // num_threads)

    threads = []
    start_time = time.time()
    for _ in range(num_threads):
        thread = threading.Thread(target=worker)
        thread.start()
        threads.append(thread)

    for thread in threads:
        thread.join()

    end_time = time.time()
    return end_time - start_time


def test_mp(v: int, num_processes: int) -> float:
    with multiprocessing.Pool(processes=num_processes) as pool:
        start_time = time.time()
        pool.map(load, [v // num_processes] * num_processes)
        end_time = time.time()

    return end_time - start_time


def run_experiments(n: int, test_func: Callable, load_var: int, *args) -> float:
    times = []
    for i in range(n):
        random.seed(i)
        time_taken = test_func(load_var, *args)
        times.append(time_taken)
    average_time = sum(times) / len(times)
    print(f"Average time: {average_time:.4f} seconds\n")
    return average_time


if __name__ == '__main__':
    print(f"Using GIL: {sys._is_gil_enabled()}\n")

    # adjust as needed for testing
    load_var = 10**3
    n_exp = 30
    n_threads = 8
    n_processes = 8

    print("Single-threaded test:")
    run_experiments(n_exp, test_st, load_var)

    print(f"Multi-threaded test with {n_threads} threads:")
    run_experiments(n_exp, test_mt, load_var, n_threads)

    print(f"Multi-processing test with {n_processes} processes:")
    run_experiments(n_exp, test_mp, load_var, n_processes)
