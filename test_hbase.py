# https://happybase.readthedocs.org/en/latest/
# https://github.com/wbolster/happybase
import happybase

def main():
    HOST='hbase-docker'
    PORT=9090
    # Will create and then delete this table
    TABLE_NAME='table-name'
    ROW_KEY='row-key'
    
    connection = happybase.Connection(HOST, PORT)

    tables = connection.tables()
    print "HBase has tables {0}".format(tables)

    if TABLE_NAME not in tables:
      print "Creating table {0}".format(TABLE_NAME)
      connection.create_table(TABLE_NAME, { 'family': dict() } )


    table = connection.table(TABLE_NAME)

    print "Storing values with row key '{0}'".format(ROW_KEY)
    table.put(ROW_KEY, {'family:qual1': 'value1',
                        'family:qual2': 'value2'})

    print "Getting values for row key '{0}'".format(ROW_KEY)
    row = table.row(ROW_KEY)
    print row['family:qual1']

    print "Printing rows with keys '{0}' and row-key-2".format(ROW_KEY)
    for key, data in table.rows([ROW_KEY, 'row-key-2']):
        print key, data

    print "Scanning rows with prefix 'row'"
    for key, data in table.scan(row_prefix='row'):
        print key, data  # prints 'value1' and 'value2'

    print "Deleting row '{0}'".format(ROW_KEY)
    row = table.delete(ROW_KEY)

    print "Deleting table {0}".format(TABLE_NAME)
    connection.delete_table(TABLE_NAME, disable=True)

if __name__ == "__main__":
    main()
