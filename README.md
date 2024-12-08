<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Sudoku-by-L2G-20050714.svg/640px-Sudoku-by-L2G-20050714.svg.png" alt="Logo" width="280" height="280">
  </a>

  <h3 align="center">Sudoku Solver</h3>


</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#objectives">Objectives</a></li>
      </ul>
    </li>
    <li><a href="#fundamental">Fundamentals</a></li>
    <li><a href="#conclusion">Conclusion</a></li>
    <li><a href="#summary">Summary</a></li>
    <li><a href="#contributing">Contributing</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Proyek Sudoku Solver ini adalah solusi berbasis perangkat keras untuk menyelesaikan Sudoku menggunakan VHDL dan FPGA. Sistem ini menggunakan pendekatan Finite State Machine untuk mengelola seluruh proses penyelesaian, mulai dari mengidentifikasi cell kosong hingga melakukan tebakan yang valid dan mundur jika diperlukan. Input yang diberikan berupa grid, dan sistem menggunakan representasi bitmap untuk melacak validitas setiap angka yang mungkin pada setiap baris, kolom, dan blok. Dengan algoritma pencarian yang efisien, sistem ini menyelesaikan langkah demi langkah, memperbarui grid hingga solusi ditemukan. Proyek ini menunjukkan penerapan praktis dari FSM dalam penyelesaian, sekaligus menunjukkan bagaimana FPGA dapat dimanfaatkan untuk masalah komputasi. Simulasi dilakukan menggunakan ModelSim menunjukkan bahwa puzzle berhasil diselesaikan dengan setiap langkah terlihat jelas di waveform, dan sistem bertransisi antar state untuk penyelesaiannya. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Objectives
- Menerapkan Algoritma Penyelesaian Sudoku pada FPGA dengan VHDL
- Mengoptimalkan Penggunaan Finite State Machine dengan backtracking.
- Mempercepat Proses Penyelesaian Sudoku dengan Hardware: 

<p align="right">(<a href="#readme-top">back to top</a>)</p>  

### Built With
- VS Code
- MODELSIM
- Intel Quartus Pro

  <p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Fundamental

Proyek ini mengimplementasikan algoritma backtracking untuk mengisi sel-sel kosong dalam teka-teki Sudoku dengan angka valid, sambil memeriksa kendala-kendala yang ada. Untuk meningkatkan efisiensi, digunakan bitmap untuk memetakan angka-angka yang sudah ada pada baris, kolom, dan blok tertentu. Bitmap baris, kolom, dan blok digunakan untuk memvalidasi angka yang bisa ditempatkan pada setiap sel kosong dengan memeriksa apakah angka tersebut sudah ada pada peta yang relevan. Dengan cara ini, sistem dapat dengan cepat menentukan angka yang valid untuk dimasukkan, sekaligus meminimalkan pencarian yang tidak perlu. Input buffer dari pengguna memungkinkan pemilihan angka yang tepat berdasarkan peta-peta tersebut. Berikut adalah gambarannya:

| Sudoku               |
|----------------------|
| ![Signal Puzzle](Image/Puzzle.png) |
| Column               |
| ![Column](Image/Column.png)       |
| Row               |
| ![ROW](Image/ROW.png)             |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Summary
Function untuk menentukan nomor blok dalam puzzle Sudoku berdasarkan indeks baris dan kolom.
```vhdl
function block_number_function(i, j: integer) return integer is
    variable block_i : integer range 0 to 10;
    variable block_j : integer range 0 to 10;
    variable block_number: integer range 0 to 9;
begin
    block_i := ((i-1) - ((i-1) mod 3)) + 1;
    block_j := ((j-1) - ((j-1) mod 3)) + 1;
    case (block_i * 10 + block_j) is
        when 11 => block_number := 1;
        when 14 => block_number := 2;
        when others => block_number := 0;
    end case;
    return block_number;
end function;
```

Mengatur transisi status FSM
```vhdl
process(clk, reset, start)
begin
    case state_present is
        when idle =>
            if (start = '1') then
                state_next <= next_empty_cell;
            else
                state_next <= idle;
            end if;

        when next_empty_cell =>
            if (next_cell_found = '1') then
                state_next <= guess;
            elsif (all_cell_filled = '1') then
                state_next <= solve;
            else
                state_next <= next_empty_cell;
            end if;

        when guess =>
            if (error = '1') then
                state_next <= backtrack;
            elsif (valid = '1') then
                state_next <= next_empty_cell;
            else
                state_next <= guess;
            end if;

        when backtrack =>
            if (restored_last_valid_fill = '1') then
                state_next <= guess;
            else
                state_next <= backtrack;
            end if;

        when solve =>
            state_next <= idle;
    end case;
end process;
```
Logic untuk FSM
```vhdl
process(state_present, clk)
    variable guess_report : guess_type := (others => ('0')); 
    variable Test_variable: integer range 0 to 9;
    begin
        case state_present is
            when idle =>
                -- Initialization
                -- Processing

            when next_empty_cell =>
                -- Logic pencarian

            when guess =>
                -- Logic menebak

            when backtrack =>
                -- Logic backtrack

            when solve =>
                -- Puzzle solved, setting ready = 1
        end case;
    end process;
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Conclusion
Proyek Sudoku Solver mengimplementasikan algoritma backtracking untuk menyelesaikan puzzle Sudoku dengan menggunakan bitmap untuk efisiensi pengecekan validitas angka di baris, kolom, dan blok. Sistem ini dapat secara otomatis mencari dan mengisi cell kosong, serta melakukan backtrack saat menemui kendala. Dengan pendekatan berbasis state machine (FSM).
<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Contributors:

<a href="https://github.com/nlsnlaurensius/Proyek-Akhir-PSD-PA19/g  raphs/contributors">
  <img src="https://contrib.rocks/image?repo=nlsnlaurensius/Proyek-Akhir-PSD-PA19" />
</a>
<a href="https://github.com/Tinkermannn/Money-Convert/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Tinkermannn/Money-Convert" />
</a>

<p><br></p>

**Wilman Saragih Sitio		2306161776  
Ammar Fattan R			2306266981  
Nelson Laurensius			2306161845  
Aisya Rivelia Azzahra		2306161864**




<p align="right">(<a href="#readme-top">back to top</a>)</p>

Project Link: [FInal Project PA-19](https://github.com/nlsnlaurensius/Proyek-Akhir-PSD-PA19)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[contributors-shield]: https://img.shields.io/github/contributors/nlsnlaurensius/Proyek-Akhir-PSD-PA19.svg?style=for-the-badge 
[contributors-url]: https://github.com/nlsnlaurensius/Proyek-Akhir-PSD-PA19/graphs/contributors
