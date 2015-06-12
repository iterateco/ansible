class FilterModule(object):
    ''' Custom filters are loaded by FilterModule objects '''

    def filters(self):
        ''' FilterModule objects return a dict mapping filter names to
            filter functions. '''
        return {
            'expand': self.expand,
        }

    ''' Expands varName into multiple host entries, separated by ':'.
        Example: {{ someVar | expand("tag_Name_")}}
        If someVar = 'apple,orange' then results is:
        'tag_Name_apple:tag_Name_orange'  '''
    def expand(self, value, varName):
        if ',' in value:
            vArray = value.split(',')
        else:
            vArray = [value]
        result = ''
        for v in vArray:
            result += ':' + varName + v
        return result[1:]