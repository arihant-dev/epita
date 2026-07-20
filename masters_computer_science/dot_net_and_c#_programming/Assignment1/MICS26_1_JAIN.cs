using System;
using System.Collections.Generic;
using System.Text;

namespace Assignment1
{
    public enum Category
    {
        COUNTRY,
        URBAN,
        SHORE
    }

    public abstract class PropertyToRent : IComparable
    {
        private string _name = "Unnamed";
        private Category _category;
        private int _price = 1;
        private int _surface = 1;

        public string Name
        {
            get { return _name; }
            set
            {
                if (!string.IsNullOrEmpty(value))
                    _name = value;
            }
        }

        public Category Category
        {
            get { return _category; }
            set { _category = value; }
        }

        public int Price
        {
            get { return _price; }
            set
            {
                if (value > 0)
                    _price = value;
            }
        }

        public int Surface
        {
            get { return _surface; }
            set
            {
                if (value > 0)
                    _surface = value;
            }
        }

        public PropertyToRent(string name, Category category, int price, int surface)
        {
            Name = name;
            Category = category;
            Price = price;
            Surface = surface;
        }

        public virtual int Taxes()
        {
            return 0;
        }

        public int CompareTo(object? obj)
        {
            if (obj is PropertyToRent other)
            {
                return Price.CompareTo(other.Price);
            }
            throw new ArgumentException("Object is not a PropertyToRent");
        }

        public override string ToString()
        {
            return $"{Category}\tPrice={Price}\t\t@={Name}\tSurface={Surface}";
        }
    }

    public class House : PropertyToRent
    {
        public House() : base("Unnamed", Category.COUNTRY, 1, 1)
        {
        }

        public House(string name, Category category, int price, int surface)
            : base(name, category, price, surface)
        {
        }

        public override int Taxes()
        {
            switch (Category)
            {
                case Category.COUNTRY:
                    return Surface * 15;
                case Category.URBAN:
                    return Surface * 25;
                case Category.SHORE:
                    return Surface * 35;
                default:
                    return 0;
            }
        }
    }

    public class Studio : PropertyToRent
    {
        public Studio() : base("Unnamed", Category.COUNTRY, 1, 1)
        {
        }

        public Studio(string name, Category category, int price, int surface)
            : base(name, category, price, surface)
        {
        }

        public override int Taxes()
        {
            switch (Category)
            {
                case Category.COUNTRY:
                    return Surface * 10;
                case Category.URBAN:
                    return Surface * 15;
                case Category.SHORE:
                    return Surface * 20;
                default:
                    return 0;
            }
        }
    }

    public class Mansion : PropertyToRent
    {
        public Mansion() : base("Unnamed", Category.COUNTRY, 1, 1)
        {
        }

        public Mansion(string name, Category category, int price, int surface)
            : base(name, category, price, surface)
        {
        }

        public override int Taxes()
        {
            switch (Category)
            {
                case Category.COUNTRY:
                    return Surface * 20;
                case Category.URBAN:
                    return Surface * 30;
                case Category.SHORE:
                    return Surface * 40;
                default:
                    return 0;
            }
        }
    }

    public class RealEstateAgency
    {
        private List<PropertyToRent> _Rentals;

        public RealEstateAgency()
        {
            _Rentals = new List<PropertyToRent>();
        }

        public void DefaultInit()
        {
            _Rentals.Add(new Studio("Les Raisins, flat 5", Category.COUNTRY, 300, 30));
            _Rentals.Add(new House("Mon Abri Cotier", Category.COUNTRY, 1200, 300));
            _Rentals.Add(new Mansion("Les Grands Platanes", Category.URBAN, 3000, 1000));
            _Rentals.Add(new Studio("Les Hautes Grarennes, flat 56", Category.URBAN, 250, 25));
            _Rentals.Add(new House("La Brise", Category.SHORE, 960, 200));
            _Rentals.Add(new House("La Chaumiere", Category.COUNTRY, 800, 150));
            _Rentals.Add(new Mansion("Les Ratelieres", Category.SHORE, 2800, 1200));
            _Rentals.Add(new Studio("Les basses plaines", Category.URBAN, 700, 47));
            _Rentals.Add(new Mansion("La Lanterne", Category.URBAN, 3500, 600));
            _Rentals.Add(new Studio("La Courvieille, flat 34", Category.COUNTRY, 340, 26));
            _Rentals.Add(new House("Ici chez moi", Category.URBAN, 780, 230));
            _Rentals.Add(new Studio("Les Saules, flat 135", Category.SHORE, 390, 30));
        }

        public void Sort()
        {
            _Rentals.Sort();
        }

        public override string ToString()
        {
            StringBuilder sb = new StringBuilder();
            foreach (PropertyToRent property in _Rentals)
            {
                sb.AppendLine(property.ToString());
            }
            return sb.ToString();
        }
    }

    public class Program
    {
        public static void Main(string[] args)
        {
            RealEstateAgency agency = new RealEstateAgency();
            agency.DefaultInit();

            Console.WriteLine("BASE SHOP CATALOG");
            Console.Write(agency.ToString());

            agency.Sort();

            Console.WriteLine("\nSORTED SHOP CATALOG");
            Console.Write(agency.ToString());
        }
    }
}
