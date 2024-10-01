def compute_ftp_rate(input: ComputeFTPInput) -> str:
    currency_input = input.currency.upper().strip()
    product_type_input = input.product_type.strip()

    # Map user inputs to DataFrame values
    product_type_mapping = {
        'reit equities': 'Equity - REIT',
        'reit equity': 'Equity - REIT',
        # Add more mappings as needed
    }

    product_type = product_type_mapping.get(product_type_input.lower(), product_type_input)

    # Filter DataFrame based on inputs
    df_filtered = df_flame[
        (df_flame['Currency'] == currency_input) &
        (df_flame['Product Type'] == product_type)
    ]

    if df_filtered.empty:
        return f"No data found for Currency: {currency_input} and Product Type: {product_type}"

    # Get the first matching row
    row = df_filtered.iloc[0]

    # Extract values
    term_funding_haircut = row['Term Funding Haircut']
    short_term_unsecured_rate = row['Short Term Unsecured Rate']
    long_term_funding_rate = row['Long Term Funding Rate']
    base_funding_rate = row['Base Funding Rate']

    # Convert Base Funding Rate from percentage to decimal
    base_funding_rate_decimal = base_funding_rate / 100

    # Check if Short Term Unsecured Rate is zero
    if short_term_unsecured_rate == 0:
        # Compute FTP Rate as difference between Base Funding Rate and Long Term Funding Rate
        ftp_rate = base_funding_rate_decimal - long_term_funding_rate

        # Convert rates to percentages for display
        long_term_funding_rate_pct = long_term_funding_rate * 100
        ftp_rate_pct = ftp_rate * 100

        # Prepare the formula string
        formula_str = "FTP Rate = Base Funding Rate - Long Term Funding Rate"

        # Prepare the calculation string
        calculation_str = f"FTP Rate = {base_funding_rate:.2f}% - {long_term_funding_rate_pct:.2f}% = {ftp_rate_pct:.2f}%"

        return (
            f"The FTP rate for {product_type} in {currency_input} is {ftp_rate_pct:.2f}%.\n\n"
            f"This is an HQLA-equivalent asset.\n\n"
            f"Formula:\n{formula_str}\n\n"
            f"Calculation:\n{calculation_str}"
        )
    else:
        # Compute FTP Rate as before
        ftp_rate = (1 - term_funding_haircut) * short_term_unsecured_rate + term_funding_haircut * long_term_funding_rate

        # Convert rates to percentages for display
        term_funding_haircut_pct = term_funding_haircut * 100
        short_term_unsecured_rate_pct = short_term_unsecured_rate * 100
        long_term_funding_rate_pct = long_term_funding_rate * 100
        ftp_rate_pct = ftp_rate * 100

        # Prepare the formula string
        formula_str = (
            "FTP Rate = (1 - Term Funding Haircut) * Short Term Unsecured Rate "
            "+ Term Funding Haircut * Long Term Funding Rate"
        )

        # Prepare the calculation string
        calculation_str = (
            f"FTP Rate = (1 - {term_funding_haircut_pct:.2f}%) * {short_term_unsecured_rate_pct:.2f}% "
            f"+ {term_funding_haircut_pct:.2f}% * {long_term_funding_rate_pct:.2f}% = {ftp_rate_pct:.2f}%"
        )

        return (
            f"The FTP rate for {product_type} in {currency_input} is {ftp_rate_pct:.2f}%.\n\n"
            f"Formula:\n{formula_str}\n\n"
            f"Calculation:\n{calculation_str}"
        )
