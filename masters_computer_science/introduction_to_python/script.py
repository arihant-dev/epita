def calculate_epita_grades():
    # Weights (ECTS) per subject 
    ects = {
        "Enterprise Essentials": 1,
        "Corporate Finance": 1,
        "Project Management": 2,
        "Communication for Leaders": 2,
        "Relational Databases": 1,
        "Operating Systems UNIX": 3,
        "Advanced Algorithmic": 3,
        "Introduction to Python": 3,
        "French": 4,
        "Cultural Integration Workshop": 1,
        "Managing Culture Shock": 1,
        "Digital Transformation": 2,
        "Blockchain & Bitcoin": 2,
        "Data Privacy by Design": 2,
        "Network Protocols": 2
    }

    # Your marks as per the transcript 
    # Replace None with values to test your final average
    marks = {
        "Enterprise Essentials": 14.45,
        "Corporate Finance": 11.3,
        "Project Management": 16.6,
        "Communication for Leaders": 15.0,
        "Relational Databases": 20.0,
        "Operating Systems UNIX": 18.95,
        "Advanced Algorithmic": 18.88,  # Enter test value here
        "Introduction to Python": 20.0,
        "French": 17.4,
        "Cultural Integration Workshop": 18.0, # Assumed based on French grade TU
        "Managing Culture Shock": 18.0,        # Assumed based on French grade TU
        "Digital Transformation": 14.25,
        "Blockchain & Bitcoin": 13.0,
        "Data Privacy by Design": 15.2,
        "Network Protocols": 13      # Enter test value here
    }

    # Define Teaching Units (T.U.) 
    tus = {
        "Advanced Management": ["Enterprise Essentials", "Corporate Finance", "Project Management", "Communication for Leaders"],
        "Programming Skills": ["Relational Databases", "Operating Systems UNIX", "Advanced Algorithmic", "Introduction to Python"],
        "Cultural Integration": ["French", "Cultural Integration Workshop", "Managing Culture Shock"],
        "Technical Foundation": ["Digital Transformation", "Blockchain & Bitcoin", "Data Privacy by Design", "Network Protocols"]
    }

    print("--- EPITA Semester 1 Grade Report ---")
    total_weighted_sum = 0
    total_ects = sum(ects.values())

    for tu_name, subjects in tus.items():
        tu_weighted_sum = 0
        tu_ects = 0
        
        for sub in subjects:
            val = marks[sub] if marks[sub] is not None else 0
            tu_weighted_sum += val * ects[sub]
            tu_ects += ects[sub]
        
        tu_grade = tu_weighted_sum / tu_ects
        total_weighted_sum += tu_weighted_sum
        print(f"{tu_name}: {tu_grade:.2f} / 20")

    final_average = total_weighted_sum / total_ects
    print("-" * 37)
    print(f"OVERALL SEMESTER AVERAGE: {final_average:.2f} / 20")

if __name__ == "__main__":
    calculate_epita_grades()