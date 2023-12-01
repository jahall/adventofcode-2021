use std::env;
use std::fs;

mod day1;


fn main() {
    let args: Vec<String> = env::args().collect();
    let data: Data = Data::new(&args);
    
    if data.day.starts_with("1") {
        day1::run(data.content);
    }
}

struct Data {
    day: String,
    content: String,
}

impl Data {
    fn new(args: &[String]) -> Data {
        let day = args[1].trim();
        let path = format!(
            "/Users/Joe/src/adventofcode/2023/data/day{day}.txt");

        let error_msg = format!("Cannot find {path}");
        let content = fs::read_to_string(path).expect(&error_msg);
        Data { day: day.to_string(), content }
    }
}