def calculate_semester_1():
    """Calculate Semester 1 grades."""
    # Weights (ECTS) per subject
    ects = {
        "Advanced Algorithmic": 3,
        "Operating Systems UNIX": 3,
        "Introduction to Python": 3,
        "Enterprise Essentials": 1,
        "Corporate Finance": 1,
        "Project Management": 2,
        "Communication for Leaders": 2,
        "Relational Databases": 1,
        "French": 4,
        "Cultural Integration Workshop": 1,
        "Managing Culture Shock": 1,
        "Digital Transformation": 2,
        "Blockchain & Bitcoin": 2,
        "Data Privacy by Design": 2,
        "Network Protocols": 2
    }

    # Your marks - Replace with actual values
    marks = {
        "Advanced Algorithmic": 18.88,
        "Operating Systems UNIX": 18.95,
        "Introduction to Python": 20.0,
        "Enterprise Essentials": 14.45,
        "Corporate Finance": 11.3,
        "Project Management": 16.6,
        "Communication for Leaders": 15.0,
        "Relational Databases": 20.0,
        "French": 17.4,
        "Cultural Integration Workshop": 18.0,
        "Managing Culture Shock": 18.0,
        "Digital Transformation": 14.25,
        "Blockchain & Bitcoin": 13.0,
        "Data Privacy by Design": 15.2,
        "Network Protocols": 13.0
    }

    # Define Teaching Units (T.U.)
    tus = {
        "Programming Skills": ["Advanced Algorithmic", "Operating Systems UNIX", "Introduction to Python", "Relational Databases"],
        "Advanced Management": ["Enterprise Essentials", "Corporate Finance", "Project Management", "Communication for Leaders"],
        "Cultural Integration": ["French", "Cultural Integration Workshop", "Managing Culture Shock"],
        "Technical Foundation": ["Digital Transformation", "Blockchain & Bitcoin", "Data Privacy by Design", "Network Protocols"]
    }

    return calculate_semester(1, ects, marks, tus)


def calculate_semester_2():
    """Calculate Semester 2 grades."""
    ects = {
        "Career Project Elaboration": 1,
        "Digital Marketing And Social Media Strategy": 1,
        "Green IT": 1,
        "ITIL": 2,
        "French Language Program MSc": 4,
        "Advanced C": 3,
        "Software & Database Security": 2,
        "Android Initiation": 2,
        "Introduction to iOS": 2,
        "OOA & UML & Java": 3,
        "Big Data Infrastructure & Cloud Computing": 3,
        "Kaggle Week": 5,
    }

    # Your marks - Replace with actual values
    marks = {
        "Career Project Elaboration": 18,
        "Digital Marketing And Social Media Strategy": 15,
        "Green IT": 16,
        "ITIL": 17,
        "French Language Program MSc": 19.41,
        "Advanced C": 16,
        "Software & Database Security": 18.5,
        "Android Initiation": 18,
        "Introduction to iOS": 18,
        "OOA & UML & Java": 20,
        "Big Data Infrastructure & Cloud Computing": 18,
        "Kaggle Week": 19,
    }

    # Define Teaching Units (T.U.) - Logical groupings by theme
    tus = {
        "Core Programming & Databases": ["Advanced C", "OOA & UML & Java"],
        "Mobile Development": ["Android Initiation", "Introduction to iOS"],
        "Big Data & Cloud": ["Big Data Infrastructure & Cloud Computing", "Kaggle Week"],
        "Infrastructure & Quality": ["Software & Database Security", "ITIL", "Green IT"],
        "Business & Languages": ["Digital Marketing And Social Media Strategy", "French Language Program MSc", "Career Project Elaboration"],
    }

    return calculate_semester(2, ects, marks, tus)


def calculate_semester_3():
    """Calculate Semester 3 grades."""
    ects = {
        "Cross-Border Management": 1,
        "Knowledge Management & Innovation": 3,
        "French Language Program MSc": 4,
        ".Net And C# Programming": 5,
        "Advanced Databases": 1,
        "Advanced Java Programming": 2,
        "Structured Data & Transportation": 1,
        "How To Use Devops Approach": 1,
        "Software Industrialization": 1,
        "Software Quality Assurance": 1,
        "Action Learning": 4,
        "Advanced Javascript": 1,
        "Web Applications Patterns": 2,
        "General Front-end development principles": 1,
        "Front-End applications": 1,
        "Progressive Web Applications": 1,
        "Stage de fin d'études": 30,
    }

    # Your marks - Replace with actual values
    marks = {
        "Cross-Border Management": None,
        "Knowledge Management & Innovation": None,
        "French Language Program MSc": None,
        ".Net And C# Programming": None,
        "Advanced Databases": None,
        "Advanced Java Programming": None,
        "Structured Data & Transportation": None,
        "How To Use Devops Approach": None,
        "Software Industrialization": None,
        "Software Quality Assurance": None,
        "Action Learning": None,
        "Advanced Javascript": None,
        "Web Applications Patterns": None,
        "General Front-end development principles": None,
        "Front-End applications": None,
        "Progressive Web Applications": None,
        "Stage de fin d'études": None,
    }

    # Define Teaching Units (T.U.) - Logical groupings by theme
    tus = {
        "Backend Development": [".Net And C# Programming", "Advanced Java Programming", "Advanced Databases"],
        "Frontend Development": ["Advanced Javascript", "Web Applications Patterns", "General Front-end development principles", "Front-End applications", "Progressive Web Applications"],
        "DevOps & Quality": ["How To Use Devops Approach", "Software Industrialization", "Software Quality Assurance", "Structured Data & Transportation"],
        "Management & Knowledge": ["Cross-Border Management", "Knowledge Management & Innovation", "Action Learning"],
        "Languages & Internship": ["French Language Program MSc", "Stage de fin d'études"],
    }

    return calculate_semester(3, ects, marks, tus)


def calculate_semester(semester_num, ects, marks, tus):
    """Generic semester calculation function."""
    print(f"\n--- EPITA Semester {semester_num} Grade Report ---")
    total_weighted_sum = 0
    total_ects = sum(ects.values())

    for tu_name, subjects in tus.items():
        tu_weighted_sum = 0
        tu_ects = 0

        for sub in subjects:
            val = marks[sub] if marks[sub] is not None else 0
            tu_weighted_sum += val * ects[sub]
            tu_ects += ects[sub]

        if tu_ects > 0:
            tu_grade = tu_weighted_sum / tu_ects if tu_weighted_sum > 0 else 0
            total_weighted_sum += tu_weighted_sum
            print(f"{tu_name}: {tu_grade:.2f} / 20")

    final_average = total_weighted_sum / total_ects if total_ects > 0 else 0
    print("-" * 37)
    print(f"OVERALL SEMESTER {semester_num} AVERAGE: {final_average:.2f} / 20")
    return final_average


def calculate_all_semesters():
    """Calculate all three semesters and overall average."""
    s1_avg = calculate_semester_1()
    s2_avg = calculate_semester_2()
    s3_avg = calculate_semester_3()

    print("\n" + "=" * 37)
    print("CUMULATIVE RESULTS")
    print("=" * 37)
    print(f"Semester 1 Average: {s1_avg:.2f} / 20")
    print(f"Semester 2 Average: {s2_avg:.2f} / 20")
    print(f"Semester 3 Average: {s3_avg:.2f} / 20")
    overall_avg = (s1_avg + s2_avg + s3_avg) / 3
    print(f"Overall Masters Average: {overall_avg:.2f} / 20")


if __name__ == "__main__":
    # Calculate all semesters
    # calculate_all_semesters()

    # Or calculate individual semesters:
    # calculate_semester_1()
    calculate_semester_2()
    # calculate_semester_3()